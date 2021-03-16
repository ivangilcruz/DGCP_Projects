SELECT  
    DISTINCT 
    c.ExternalId C_CODIGO_UNIDAD_COMPRA
    ,pr.Reference AS CODIGO_PROCESO
    ,CASE 
        WHEN pr.Reference LIKE '%-CD-%' THEN 'Compras por Debajo del Umbral'
        WHEN pr.Reference LIKE '%-CM-%' THEN 'Compras Menores'
        WHEN pr.Reference LIKE '%-LPN-%' THEN 'Licitación Pública Nacional'
        WHEN pr.Reference LIKE '%-CP-%' THEN 'Comparación de Precios'
        WHEN pr.Reference LIKE '%-SO-%' THEN 'Sorteo de Obras'
        WHEN pr.Reference LIKE '%-LPI-%' THEN 'Licitación Pública Internacional'
        WHEN pr.Reference LIKE '%-LR-%' THEN 'Licitación Restringida'
        WHEN pr.Reference LIKE '%-SI-%' THEN 'Subasta Inversa'
            
        WHEN pr.Reference LIKE '%-PEUR-%' THEN 'Procesos de Excepción'
        WHEN pr.Reference LIKE '%-PEEN-%' THEN 'Procesos de Excepción'
        WHEN pr.Reference LIKE '%-PEOR-%' THEN 'Procesos de Excepción'
        WHEN pr.Reference LIKE '%-PEEX-%' THEN 'Procesos de Excepción'
        WHEN pr.Reference LIKE '%-PEPU-%' THEN 'Procesos de Excepción'
        WHEN pr.Reference LIKE '%-PECO-%' THEN 'Procesos de Excepción'
        WHEN pr.Reference LIKE '%-PERC-%' THEN 'Procesos de Excepción'
        WHEN pr.Reference LIKE '%-PEPB-%' THEN 'Procesos de Excepción'
        WHEN pr.Reference LIKE '%-PE15-%' THEN 'Procesos de Excepción'

        WHEN pr.Reference LIKE '%-PESN-%' THEN 'Procesos de Excepción Seguridad Nacional'
        ELSE 'No definido'
    END MODALIDAD
    ,CASE 
        WHEN pr.Reference LIKE '%-PEUR-%' THEN 'urgencia'
        WHEN pr.Reference LIKE '%-PEEN-%' THEN 'emergencia'
        WHEN pr.Reference LIKE '%-PESN-%' THEN 'seguridad nacional'
        WHEN pr.Reference LIKE '%-PEOR-%' THEN 'obras cientificas, tecnicas,artisticas,restauracion de monumentos'
        WHEN pr.Reference LIKE '%-PEEX-%' THEN 'exclusividad'
        WHEN pr.Reference LIKE '%-PEPU-%' THEN 'proveedor unico'
        WHEN pr.Reference LIKE '%-PECO-%' THEN 'construccion de oficinas para el servicio exterior'
        WHEN pr.Reference LIKE '%-PERC-%' THEN 'recision de contratos'
        WHEN pr.Reference LIKE '%-PEPB-%' THEN 'publicidad'
        WHEN pr.Reference LIKE '%-PE15-%' THEN 'pasajes aereos, reparaciones y combustibles'
        ELSE 'proceso ordinario'
    END TIPO_EXCEPCION
    ,CASE          
        WHEN pr.[State] = 'Awarded' then 'Proceso adjudicado y celebrado'  
        WHEN pr.[State] = 'Canceled' AND cn.UniqueIdentifier IS NOT NULL THEN 'Cancelado'     
        WHEN pr.[State] = 'Closed' then 'Aun no publicado'       
        WHEN pr.[State] = 'ClosedForReplies' then 'Proceso con etapa cerrada'   
        WHEN pr.[State] = 'InEdition' then 'Aun no publicado'         
        WHEN pr.[State] = 'NonAwarded' then 'Proceso desierto'         
        WHEN pr.[State] = 'Opened' then 'Sobres abiertos ó aperturados'     
        WHEN pr.[State] = 'Published' then 'Proceso publicado'         
        WHEN pr.[State] = 'RepliesOpenningStarted' then 'Sobres están abriéndose'  
        WHEN pr.[State] = 'UnderApproval' then 'Aun no publicado'         
        WHEN pr.[State] = 'WaitingForPublicationDate' then 'Aun no publicado'
        WHEN pr.[State] = 'Rejected' then 'Aun no publicado'
        WHEN pr.[State] = 'Approved' then 'Aun no publicado'
        WHEN pr.[State] = 'Canceled' then 'Aun no publicado'
        ELSE pr.[State]         
    END PR_ESTADO_PROCESO
    --,bil.Id as Id
    ,bil.CategoryCode as UNSPSC
    ,SUBSTRING(bil.CategoryCode, 1, 6) + '00' CLASE
    --bil.*,
    --VCC.Description
    ,fechas.FechaPublicacion AS FECHA_PUBLICACION
FROM    (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY Reference ORDER BY CreateDate DESC) AS ranking
            FROM ProcedureRequest
        ) pr 
INNER JOIN ContractNotice cn WITH (NOLOCK)
    ON cn.RequestUniqueIdentifier=pr.UniqueIdentifier
INNER JOIN RequestData rd WITH (NOLOCK)
    ON rd.ProcedureRequestData=pr.Id
INNER JOIN BusinessItemOutlineContainer biolc WITH (NOLOCK)
    ON rd.Id=biolc.RequestDataDataSheetDivisions
INNER JOIN BusinessItemOutline biol WITH (NOLOCK)
    ON biolc.Id=biol.BusinessItemOutlineContainerOutlines
INNER JOIN BusinessItem bi WITH (NOLOCK)
    ON biol.id=bi.BusinessItemOutlineBusinessItem
INNER JOIN BusinessItemLine bil WITH (NOLOCK)
    ON bi.Id=bil.BusinessItemLines
INNER JOIN Category VCC WITH (NOLOCK)
    ON BIL.CategoryCode=VCC.Code
LEFT JOIN Company c WITH (NOLOCK)
    ON pr.CreateCompanyCode=c.Code
LEFT JOIN (
        SELECT *
    FROM
    (
        SELECT
        ProcedureRequestSchedule,
        CASE Type
            WHEN 0 THEN 'FechaPublicacion'
            ELSE 'No especificado'
        END Fecha,
        DATEADD(HOUR, -4, SelectedDateTime) SelectedDateTimeMinus4Hours
        FROM [Portal].[dbo].[RequestDate]
    ) AS SourceTable PIVOT(MAX([SelectedDateTimeMinus4Hours]) FOR [Fecha] IN(
                                                                            [FechaPublicacion],
                                                                            [No especificado])) AS PivotTable
) fechas
ON fechas.ProcedureRequestSchedule=pr.Id
WHERE bil.AccountCode IS NOT NULL AND pr.ranking=1 AND fechas.FechaPublicacion >= DATEADD(MONTH, -3, getdate())