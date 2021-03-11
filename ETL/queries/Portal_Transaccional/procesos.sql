SELECT
        pr.Id PR_ID_PROCESO, 
        pr.UniqueIdentifier PR_REQ_PROCESO,  
        cn.UniqueIdentifier PR_NTC_PROCESO,
        pr.BuyerDossierUniqueIdentifier PR_BDOS_PROCESO, 
        pr.PPI PR_PPI_PROCESO, 
        pr.Reference PR_CODIGO_PROCESO, 
        pr.Name PR_CARATULA,
        pr.Description PR_DESCRIPCION,
        CASE 
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
        END PR_MODALIDAD,
        CASE 
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
        END TIPO_EXCEPCION,
        CASE          
            WHEN pr.[State] = 'Awarded' then 'Proceso adjudicado y celebrado'  
            WHEN pr.[State] = 'Canceled' AND cn.UniqueIdentifier IS NOT NULL THEN 'Cancelado'     
            --WHEN pr.[State] = 'Closed' then 'Cerrada la recepción de ofertas'       
            WHEN pr.[State] = 'ClosedForReplies' then 'Proceso con etapa cerrada'   
            --WHEN pr.[State] = 'InEdition' then 'En edición'         
            WHEN pr.[State] = 'NonAwarded' then 'Proceso desierto'         
            WHEN pr.[State] = 'Opened' then 'Sobres abiertos ó aperturados'     
            WHEN pr.[State] = 'Published' then 'Proceso publicado'         
            WHEN pr.[State] = 'RepliesOpenningStarted' then 'Sobres están abriéndose'  
            --WHEN pr.[State] = 'UnderApproval' then 'En aprobación'         
            --WHEN pr.[State] = 'WaitingForPublicationDate' then 'Esperando publicación'    
            ELSE pr.[State]         
        end PR_ESTADO_PROCESO,
        cn.PhaseName CN_FASE_PROCESO, 
        pr.ProcedureCurrencyCode PR_MONEDA, 
        pr.BasePrice PR_MONTO_ESTIMADO, 
        pr.CreateCompanyCode PR_ID_UNIDAD_COMPRA, 
        c.ExternalId C_CODIGO_UNIDAD_COMPRA,
        c.Name C_UNIDAD_COMPRA,
        DATEADD(HOUR, -4, pr.CreateDate) PR_FECHA_CREACION,
        rd.FechaPublicacion RD_FECHA_PUBLICACION,
        rd.FechaEnmiendas RD_FECHA_ENMIENDA,
        rd.FechaFinRecepcionOfertas RD_FECHA_FIN_RECEPCION_OFERTAS,
        rd.FechaAperturaOfertas RD_FECHA_APERTURA_OFERTAS,
        rd.FechaEstimadaAdjudicacion RD_FECHA_ESTIMADA_ADJUDICACION,
        rd.FechaSuscripcion RD_FECHA_SUSCRIPCION,
        CASE 
            WHEN pr.LimitRepliesToSmallCompanies = 0 THEN 'No'
            WHEN pr.LimitRepliesToSmallCompanies = 1 THEN 'Si'
            WHEN pr.LimitRepliesToSmallCompanies IS NULL THEN 'No especificado'
            ELSE CAST(pr.LimitRepliesToSmallCompanies AS VARCHAR)
        END PR_DIRIGIDO_MIPYMES, 
        CASE 
            WHEN pr.LimitRepliesToSmallFemaleCompanies = 0 THEN 'No'
            WHEN pr.LimitRepliesToSmallFemaleCompanies = 1 THEN 'Si'
            WHEN pr.LimitRepliesToSmallFemaleCompanies IS NULL THEN 'No especificado'
            ELSE CAST(pr.LimitRepliesToSmallFemaleCompanies AS VARCHAR)  
        END PR_DIRIGIDO_MIPYMES_MUJERES, 
        CASE 
            WHEN pr.DefineLots = 0 THEN 'No'
            WHEN pr.DefineLots = 1 THEN 'Si'
            WHEN pr.DefineLots IS NULL THEN 'No especificado'
            ELSE CAST(pr.DefineLots AS VARCHAR)  
        END PR_PROCESO_LOTIFICADO, 
        CASE 
            WHEN cn.TypeOfContractCode = 'GoodsDominicana' THEN 'Bienes'
            WHEN cn.TypeOfContractCode = 'ServicesDominicana' THEN 'Servicios'
            WHEN cn.TypeOfContractCode = 'ConstructionDominicana' THEN 'Obras'
            WHEN cn.TypeOfContractCode = 'ConcessionDominicana' THEN 'Concesiones'
            ELSE cn.TypeOfContractCode
        END CN_OBJETO_PROCESO, 
        CASE
            WHEN cn.SubTypeOfContractCode = 'GoodsDominicana' THEN 'Bienes' 
            WHEN cn.SubTypeOfContractCode = 'ConstructionDominicana' THEN 'Obras'
            WHEN cn.SubTypeOfContractCode = 'ConcessionDominicana' THEN 'Concesiones'
            WHEN cn.SubTypeOfContractCode = 'ChildServicesDominicana' THEN 'Servicios'
            WHEN cn.SubTypeOfContractCode = 'ConsultingDominicana' THEN 'Consultorías'
            WHEN cn.SubTypeOfContractCode = 'ConsultingQualityDominicana' THEN 'Consultoría basada en la calidad de los servicios'
            ELSE cn.TypeOfContractCode
        END CN_SUBOBJETO_PROCESO,
        cn.ContractDuration CN_DURACION_CONTRATO, 
        cn.NumberInvitedCompanies CN_NUMERO_PROVEEDORES_NOTIFICADOS,
        CASE
            WHEN cn.UniqueIdentifier IS NOT NULL THEN CONCAT('https://comunidad.comprasdominicana.gob.do//Public/Tendering/OpportunityDetail/Index?noticeUID=', cn.UniqueIdentifier)
            ELSE cn.UniqueIdentifier
        END URL_PUBLICA,
        CASE
            WHEN pr.UniqueIdentifier IS NOT NULL THEN CONCAT('https://portal.comprasdominicana.gob.do/DO1BusinessLine/Tendering/ProcedureEdit/View?docUniqueIdentifier=', pr.UniqueIdentifier)
            ELSE pr.UniqueIdentifier
        END URL_PRIVADA,
        CASE
            WHEN pr.UniqueIdentifier IS NOT NULL THEN CONCAT('https://comunidad.comprasdominicana.gob.do/STS/ReloadSession.aspx?currentLanguage=es-DO&ReturnUrl=https://portal.comprasdominicana.gob.do/DO1BusinessLine/Tendering/ProcedureEdit/View?docUniqueIdentifier=', pr.UniqueIdentifier, '&currentCompanyCode=', pr.CreateCompanyCode)
            ELSE pr.UniqueIdentifier
        END URL_PRIVADA2
    FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY Reference ORDER BY CreateDate DESC) AS ranking
            FROM ProcedureRequest
        ) pr
    LEFT JOIN (
        SELECT *
    FROM
    (
        SELECT
        ProcedureRequestSchedule,
        CASE Type
            WHEN 0 THEN 'FechaPublicacion'
            WHEN 4 THEN 'FechaFinRecepcionOfertas'
            WHEN 3 THEN 'FechaAperturaOfertas'
            WHEN 41 THEN 'FechaEstimadaAdjudicacion'
            WHEN 28 THEN 'FechaEnmiendas'
            WHEN 15 THEN 'FechaSuscripcion'
            ELSE 'No especificado'
        END Fecha,
        DATEADD(HOUR, -4, SelectedDateTime) SelectedDateTimeMinus4Hours
        FROM [Portal].[dbo].[RequestDate]
    ) AS SourceTable PIVOT(MAX([SelectedDateTimeMinus4Hours]) FOR [Fecha] IN([FechaPublicacion],
                                                            [FechaEnmiendas],
                                                            [FechaFinRecepcionOfertas],
                                                            [FechaAperturaOfertas],
                                                            [FechaEstimadaAdjudicacion],
                                                            [FechaSuscripcion],
                                                            [No especificado])) AS PivotTable
    ) rd
    ON pr.Id=rd.ProcedureRequestSchedule
    LEFT JOIN ContractNotice cn
    ON cn.RequestUniqueIdentifier=pr.[UniqueIdentifier]
    LEFT JOIN Company c
    ON pr.CreateCompanyCode=c.Code
where pr.ranking=1