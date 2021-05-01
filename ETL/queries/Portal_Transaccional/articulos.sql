SELECT  
    co.ExternalId CODIGO_UNIDAD_COMPRA
    ,co.Name UNIDAD_COMPRA
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
        WHEN pr.[State] = 'Closed' then 'Aun no publicado: Closed'       
        WHEN pr.[State] = 'ClosedForReplies' then 'Proceso con etapa cerrada'   
        WHEN pr.[State] = 'InEdition' then 'Aun no publicado'         
        WHEN pr.[State] = 'NonAwarded' then 'Proceso desierto'         
        WHEN pr.[State] = 'Opened' then 'Sobres abiertos ó aperturados'     
        WHEN pr.[State] = 'Published' then 'Proceso publicado'         
        WHEN pr.[State] = 'RepliesOpenningStarted' then 'Sobres están abriéndose'  
        WHEN pr.[State] = 'UnderApproval' then 'Aun no publicado: UnderApproval'         
        WHEN pr.[State] = 'WaitingForPublicationDate' then 'Aun no publicado: WaitingForPublicationDate'
        WHEN pr.[State] = 'Rejected' then 'Aun no publicado: Rejected'
        WHEN pr.[State] = 'Approved' then 'Aun no publicado: Approved'
        WHEN pr.[State] = 'Canceled' then 'Aun no publicado: Canceled'
        ELSE pr.[State]         
    END ESTADO_PROCESO
    ,CASE 
        WHEN pr.DefineLots = 0 THEN 'No'
        WHEN pr.DefineLots = 1 THEN 'Si'
        WHEN pr.DefineLots IS NULL THEN 'No especificado'
        ELSE CAST(pr.DefineLots AS VARCHAR)  
    END PROCESO_LOTIFICADO
    ,CASE 
        WHEN bd.HasPlannedAcquisitions = 0 THEN 'No'
        WHEN bd.HasPlannedAcquisitions = 1 THEN 'Si'
        WHEN bd.HasPlannedAcquisitions IS NULL THEN 'No especificado'
        ELSE CAST(bd.HasPlannedAcquisitions AS VARCHAR)  
    END ADQUISICION_PLANEADA
    ,CASE 
        WHEN pr.LimitRepliesToSmallCompanies = 0 THEN 'No'
        WHEN pr.LimitRepliesToSmallCompanies = 1 THEN 'Si'
        WHEN pr.LimitRepliesToSmallCompanies IS NULL THEN 'No especificado'
        ELSE CAST(pr.LimitRepliesToSmallCompanies AS VARCHAR)
    END DIRIGIDO_MIPYMES
    ,CASE 
        WHEN pr.LimitRepliesToSmallFemaleCompanies = 0 THEN 'No'
        WHEN pr.LimitRepliesToSmallFemaleCompanies = 1 THEN 'Si'
        WHEN pr.LimitRepliesToSmallFemaleCompanies IS NULL THEN 'No especificado'
        ELSE CAST(pr.LimitRepliesToSmallFemaleCompanies AS VARCHAR)  
    END DIRIGIDO_MIPYMES_MUJERES
    ,CASE 
        WHEN cn.TypeOfContractCode = 'GoodsDominicana' THEN 'Bienes'
        WHEN cn.TypeOfContractCode = 'ServicesDominicana' THEN 'Servicios'
        WHEN cn.TypeOfContractCode = 'ConstructionDominicana' THEN 'Obras'
        WHEN cn.TypeOfContractCode = 'ConcessionDominicana' THEN 'Concesiones'
        ELSE cn.TypeOfContractCode
    END OBJETO_PROCESO
    ,CASE
        WHEN cn.SubTypeOfContractCode = 'GoodsDominicana' THEN 'Bienes' 
        WHEN cn.SubTypeOfContractCode = 'ConstructionDominicana' THEN 'Obras'
        WHEN cn.SubTypeOfContractCode = 'ConcessionDominicana' THEN 'Concesiones'
        WHEN cn.SubTypeOfContractCode = 'ChildServicesDominicana' THEN 'Servicios'
        WHEN cn.SubTypeOfContractCode = 'ConsultingDominicana' THEN 'Consultorías'
        WHEN cn.SubTypeOfContractCode = 'ConsultingQualityDominicana' THEN 'Consultoría basada en la calidad de los servicios'
        ELSE cn.SubTypeOfContractCode
    END SUBOBJETO_PROCESO
    ,pr.Name CARATULA
    ,DATEADD(HOUR, -4, pd.SelectedDateTime) FECHA_PUBLICACION
    ,bil.Id ID_ARTICULO
    ,SUBSTRING(bil.CategoryCode, 1, 6) + '00' CLASE_UNSPSC
    ,cat_l3.Description
    ,bil.CategoryCode  SUBCLASE_UNSPSC
    ,cat_l4.Description DESCRIPCION_ARTICULO
    ,isnull(billv.[Value], bilv.[Value]) DESCRIPCION_USUARIO
FROM 
    (SELECT *, ROW_NUMBER() OVER (PARTITION BY Reference ORDER BY CreateDate DESC) AS rn FROM [DGCP-SRV-SQDHW].Portal.dbo.ProcedureRequest WITH (NOLOCK)) pr INNER JOIN
    (SELECT * FROM [DGCP-SRV-SQDHW].Portal.dbo.RequestDate WITH (NOLOCK) WHERE DATEADD(HOUR, -4, SelectedDateTime) >= DATEADD(MONTH, -3, getdate()))  pd ON pd.ProcedureRequestSchedule=pr.Id AND pd.Type=0 AND pd.SelectedDateTime IS NOT NULL AND pd.RequestUniqueName NOT LIKE '%Draft%' LEFT JOIN
    --(SELECT * FROM [DGCP-SRV-SQDHW].Portal.dbo.RequestDate WITH (NOLOCK)) pd ON pd.ProcedureRequestSchedule=pr.Id AND pd.Type=0 AND pd.SelectedDateTime IS NOT NULL AND pd.RequestUniqueName NOT LIKE '%Draft%' LEFT JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.Company co WITH (NOLOCK) ON co.Code=pr.CreateCompanyCode LEFT JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.BuyerDossier bd WITH (NOLOCK) ON pr.BuyerDossierUniqueIdentifier=bd.[UniqueIdentifier] LEFT JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.ContractNotice cn WITH (NOLOCK) ON cn.RequestUniqueIdentifier=pr.[UniqueIdentifier] INNER JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.RequestData rd WITH (NOLOCK) ON rd.ProcedureRequestData=pr.Id INNER JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.BusinessItemOutlineContainer biolc WITH (NOLOCK) ON rd.Id=biolc.RequestDataDataSheetDivisions INNER JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.BusinessItemOutline biol WITH (NOLOCK) ON biolc.Id=biol.BusinessItemOutlineContainerOutlines INNER JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.BusinessItem bi WITH (NOLOCK) ON biol.id=bi.BusinessItemOutlineBusinessItem INNER JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.BusinessItemLine bil WITH (NOLOCK) ON bi.Id=bil.BusinessItemLines AND bil.AccountCode IS NOT NULL LEFT JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.BusinessItemLineValue bilv WITH (NOLOCK) ON bilv.BusinessItemLineValues=bil.Id AND bilv.[Key]='Description' LEFT JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.BusinessItemLineLargeValue billv WITH (NOLOCK) ON billv.ParentBusinessItemLineValues=bil.Id AND billv.ParentKey='Description' INNER JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.Category cat_l4 WITH (NOLOCK) ON bil.CategoryCode=cat_l4.Code INNER JOIN
    [DGCP-SRV-SQDHW].Portal.dbo.Category cat_l3 WITH (NOLOCK) ON cat_l3.Code=SUBSTRING(bil.CategoryCode, 1, 6) + '00'
WHERE pr.rn=1