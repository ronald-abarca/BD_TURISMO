use BD_TURISMO
go
exec SP_InsCategorias '1','categoria1','descripcion1'
exec SP_InsCategorias '2','categoria2','descripcion2'
exec SP_InsCategorias '3','categoria3','descripcion3'
exec SP_InsCategorias '4','categoria4','descripcion4'
exec SP_InsCategorias '5','categoria5','descripcion5'
go
exec SP_InsDepartamentos '1','departamento1'
exec SP_InsDepartamentos '2','departamento2'
exec SP_InsDepartamentos '3','departamento3'
exec SP_InsDepartamentos '4','departamento4'
exec SP_InsDepartamentos '5','departamento5'
go
exec SP_InsMunicipios '1','municipio1','1'
exec SP_InsMunicipios '2','municipio2','1'
exec SP_InsMunicipios '3','municipio3','2'
exec SP_InsMunicipios '4','municipio4','2'
exec SP_InsMunicipios '5','municipio5','3'
go
exec SP_InsRolUsuario '1','rol1'
exec SP_InsRolUsuario '2','rol2'
exec SP_InsRolUsuario '3','rol3'
exec SP_InsRolUsuario '4','rol4'
exec SP_InsRolUsuario '5','rol5'
go
exec SP_InsAdicionales '1','adicional1','descripcion1',1.6
exec SP_InsAdicionales '2','adicional2','descripcion2',1.5
exec SP_InsAdicionales '3','adicional3','descripcion3',1.7
exec SP_InsAdicionales '4','adicional4','descripcion4',1.8
exec SP_InsAdicionales '5','adicional5','descripcion5',1.9
go
exec SP_InsFormapago '1','forma1','descripcion1',1
exec SP_InsFormapago '2','forma2','descripcion2',1
exec SP_InsFormapago '3','forma3','descripcion3',0
exec SP_InsFormapago '4','forma4','descripcion4',1
exec SP_InsFormapago '5','forma5','descripcion5',1
go
exec SP_InsPaquetes '1','Paquete1','descripcion1','direccion1',1,1,'img1'
exec SP_InsPaquetes '2','Paquete2','descripcion2','direccion2',1,1,'img2'
exec SP_InsPaquetes '3','Paquete3','descripcion3','direccion3',2,2,'img3'
exec SP_InsPaquetes '4','Paquete4','descripcion4','direccion4',2,2,'img4'
exec SP_InsPaquetes '5','Paquete5','descripcion5','direccion5',3,3,'img5'
go
exec SP_InsUsuarios '1','usuario1','apellido1',18,'1234-5671','direccion1','correo@usiario1.com',1,0
exec SP_InsUsuarios '2','usuario2','apellido2',19,'','direccion2','correo@usiario2.com',2,0
exec SP_InsUsuarios '3','usuario3','apellido3',20,'1234-5673','','correo@usiario3.com',3,1
exec SP_InsUsuarios '4','usuario4','apellido4',21,'','','correo@usiario4.com',4,0
exec SP_InsUsuarios '5','usuario5','apellido5',22,'1234-5675','direccion5','correo@usiario5.com',5,0
go
exec SP_InsPaqueteCalificacion '1','1','5',1
exec SP_InsPaqueteCalificacion '2','1','5',''
exec SP_InsPaqueteCalificacion '3','2','4',1
exec SP_InsPaqueteCalificacion '4','2','4',0
exec SP_InsPaqueteCalificacion '5','3','3',1
go
exec SP_InsCuenta 1,1,'nombre1','contra1',1
exec SP_InsCuenta 2,2,'','',0
exec SP_InsCuenta 3,3,'','contra3',1
exec SP_InsCuenta 4,4,nombre4,'',0
exec SP_InsCuenta 5,5,nombre5,contra5,1
go
exec SP_InsTelefono 1,'1234-5671',1
exec SP_InsTelefono 2,'1234-5672',2
exec SP_InsTelefono 3,'1234-5673',3
exec SP_InsTelefono 4,'1234-5674',4
exec SP_InsTelefono 5,'1234-5675',5
go
exec SP_InsPaquetesDisponible 1,1,1.6,5,0,'2023-4-8','2023-4-10',1
exec SP_InsPaquetesDisponible 2,2,1.7,10,0,'2023-4-8','2023-4-11',0
exec SP_InsPaquetesDisponible 3,3,1.8,15,0,'2023-4-8','2023-4-12',1
exec SP_InsPaquetesDisponible 4,4,1.9,20,0,'2023-4-8','2023-4-13',0
exec SP_InsPaquetesDisponible 5,5,2.1,25,0,'2023-4-8','2023-4-14',1
go
exec SP_InsEncabezado 1,1,1,2.5,6.75
exec SP_InsEncabezado 2,2,2,3.5,7.75
exec SP_InsEncabezado 3,3,3,4.5,8.75
exec SP_InsEncabezado 4,4,4,5.5,9.75
exec SP_InsEncabezado 5,5,5,6.5,10.75
go
exec SP_InsDetalle 1,1,1,1.5,2.5,3.5,1
exec SP_InsDetalle 2,2,2,1.6,2.6,3.6,2
exec SP_InsDetalle 3,3,3,1.7,2.7,3.7,3
exec SP_InsDetalle 4,4,4,1.8,2.8,3.8,4
exec SP_InsDetalle 5,5,5,1.9,2.9,3.9,5
go
exec SP_InsAdicionalesDisponible 1,1,1
exec SP_InsAdicionalesDisponible 2,2,2
exec SP_InsAdicionalesDisponible 3,3,3
exec SP_InsAdicionalesDisponible 4,4,4
exec SP_InsAdicionalesDisponible 5,5,5
go
exec SP_InsPersonasExtras 1,'nombre1','apellido1','doc1',23,1,1
exec SP_InsPersonasExtras 2,'nombre2','apellido2','doc2','',2,2
exec SP_InsPersonasExtras 3,'nombre3','apellido3','doc3',25,3,3
exec SP_InsPersonasExtras 4,'nombre4','apellido4','doc4',26,4,4
exec SP_InsPersonasExtras 5,'nombre5','apellido5','doc5',27,5,5
go
exec SP_ReCategorias
exec SP_ReDepartamentos
exec SP_ReMunicipios
exec SP_ReRolUsuario
exec SP_ReAdicionales
exec SP_ReFormapago 
exec SP_RePaquetes 
exec SP_ReUsuarios
exec SP_RePaqueteCalificacion 
exec SP_ReCuenta 
exec SP_ReTelefono 
exec SP_RePaquetesDisponible
exec SP_ReEncabezado 
exec SP_ReDetalle 
exec SP_ReAdicionalesDisponible 
exec SP_RePersonasExtras 