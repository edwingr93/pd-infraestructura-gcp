# Infraestructura GCP para tramites

Terraform para la prueba técnica. La configuración crea Artifact Registry,
Cloud Run, Secret Manager, identidades separadas para runtime y GitHub Actions,
Workload Identity Federation y una alerta de presupuesto mensual de USD 10.
El presupuesto envía alertas; no impone un límite de gasto.

Cada responsabilidad tiene su propia carpeta Terraform bajo
`platform/modules/`: `apis/`, `artifact_registry/`, `cloud_run/`, `secret_manager/`,
`identities/`, `github_deploy_permissions/` y `budget/`. El root `platform/`
conecta los módulos; `bootstrap/` crea por separado el bucket de estado.

## Arquitectura

```text
GitHub Actions --OIDC/WIF--> SA de despliegue
                                  |-- Artifact Registry (writer)
                                  |-- Cloud Run (admin)
                                  v
                            Cloud Run API
                              |-- SA runtime
                              |     `-- Secret Manager (API_KEY)
                              `-- Imagen versionada en GAR

Terraform state --> bucket GCS privado, con versionado
Budget alert --> proyecto pd-ed-gar-2026, umbrales 50%, 90%, 100%
```

## Prerrequisitos

- Terraform >= 1.3, Google Cloud CLI y acceso al proyecto `pd-ed-gar-2026`.
- Autenticarse localmente con `gcloud auth application-default login`.
- Tener una imagen ya publicada en `us-central1-docker.pkg.dev/pd-ed-gar-2026/tramites/tramites-api`, etiquetada con SHA o SemVer (no `latest`).
- La cuenta debe tener permisos para habilitar APIs, crear IAM, configurar facturación y crear recursos.

## Preparar y desplegar

1. Inicializar bootstrap con el state local e importar el bucket que ya existe:

   ```powershell
   terraform -chdir=bootstrap init
   terraform -chdir=bootstrap import google_storage_bucket.terraform_state pd-ed-gar-2026-tfstate
   terraform -chdir=bootstrap plan
   terraform -chdir=bootstrap apply
   ```

   El bucket `pd-ed-gar-2026-tfstate` ya fue creado manualmente. El import es
   necesario una sola vez para que Terraform lo administre; revisa el plan
   antes de aplicar y confirma que la ubicación y configuración existentes
   coincidan con `bootstrap/variables.tf` y `bootstrap/main.tf`. No ejecutes
   `apply` antes de importar el bucket.

2. Configurar e inicializar el backend remoto:

   ```powershell
   Copy-Item platform/backend.hcl.example platform/backend.hcl
   terraform -chdir=platform init -backend-config=backend.hcl
   ```

3. Desplegar. Sustituye el tag por el SHA o SemVer de la imagen que ya
   publicaste:

   ```powershell
   terraform -chdir=platform apply -var="image_uri=us-central1-docker.pkg.dev/pd-ed-gar-2026/tramites/tramites-api:SHA_O_SEMVER"
   ```

4. Añadir un valor ficticio de prueba como versión del secreto. No uses ni
   guardes credenciales reales en el repositorio:

   ```powershell
   "valor-ficticio-solo-para-pruebas" | gcloud secrets versions add tramites-api-key --data-file=-
   ```

5. Obtener la URL y datos de identidad:

   ```powershell
   terraform -chdir=platform output
   ```

Configura los outputs `github_workload_identity_provider` y
`github_service_account` como secrets `GCP_WORKLOAD_IDENTITY_PROVIDER` y
`GCP_SERVICE_ACCOUNT` en GitHub. Configura `GCP_PROJECT_ID`, `GCP_REGION` y
`GAR_REPOSITORY` como variables de Actions.

## Destruir

Primero destruye la plataforma y luego el bootstrap. El backend remoto seguirá
disponible hasta el segundo comando:

```powershell
terraform -chdir=platform destroy -var="image_uri=us-central1-docker.pkg.dev/pd-ed-gar-2026/tramites/tramites-api:SHA_O_SEMVER"
terraform -chdir=bootstrap destroy
```

El segundo comando elimina también el bucket y sus versiones de estado. Hazlo
solo después de destruir la plataforma y cuando ya no necesites su historial.

## Pendiente

- El workflow del repo de aplicación actualmente construye y publica, pero
  todavía hay que cambiarlo para no publicar `latest` y desplegar a Cloud Run
  con el SHA inmutable.
- La app debe consumir `API_KEY` desde el entorno sin exponer su valor. El
  servicio ya configura la referencia a Secret Manager.
- La prueba pide dos PR fusionados y `main` protegida; deben configurarse en
  GitHub y ejecutarse desde ramas `feature/{ticket}-descripcion`.
- El reto de Parte B (Binary Authorization o detección de drift) aún no está
  implementado.
- Añadir `CRITERIO.md` y completar el README de la aplicación con decisiones,
  diagrama, pendientes y uso de IA.

El asistente de código participó en cambios; conserva la atribución de
coautoría en los commits que genere.