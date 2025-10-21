import cloudinary, {UploadApiErrorResponse, UploadApiResponse} from "cloudinary"

// Sube archivos (imágenes/ZIP) a Cloudinary
export function uploads(
    file: string,           // Ruta del archivo o URL
    public_id?: string,     // ID público personalizado
    overwrite?: boolean,    // Sobrescribir si existe?
    invalidate?: boolean    // Invalidar CDN?
): Promise<UploadApiResponse | UploadApiErrorResponse | undefined> {
    return new Promise((resolve) => {
        cloudinary.v2.uploader.upload(
            file,
            {
                public_id,
                overwrite: overwrite ?? true,
                invalidate: invalidate ?? true,
                resource_type: 'auto',  // Detecta tipo automáticamente
                access_control: [{       // Control de acceso para archivos raw
                    access_type: 'anonymous'
                }]
            },
            (error, result) => error ? resolve(error) : resolve(result)
        );
    });
}

// Sube videos con configuración específica
export function videoUpload(
    file: string,
    public_id?: string,
    overwrite?: boolean,
    invalidate?: boolean
): Promise<UploadApiResponse | UploadApiErrorResponse | undefined> {
    return new Promise((resolve) => {
        cloudinary.v2.uploader.upload(
            file,
            {
                public_id,
                overwrite,
                invalidate,
                chunk_size: 50000,    // Tamaño de chunk para streaming
                resource_type: 'video' // Fuerza tipo video
            },
            (error, result) => error ? resolve(error) : resolve(result)
        );
    });
}