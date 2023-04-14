create database BD_TURISMO
go
use BD_TURISMO
go
create table departamentos(
	iddepartamento varchar(120) primary key,
	nombre varchar(50)
)
go
create table municipios(
	idmunicipio varchar(120) primary key,
	nombre varchar(50),
	iddepartamento varchar(120) foreign key references departamentos(iddepartamento)
);

go 
create table rolusuario(
	id_role varchar(64) primary key,
	r_name varchar(50) default 'USER',
	r_registro DATETIME2 default CURRENT_TIMESTAMP
);

go
create table usuarios(
	idusuario varchar(120) primary key,
	nombre varchar(100),
	apellido varchar(100),
	edad tinyint default 18,
	telefono varchar(15) default '00-00-00-00',
	direccion varchar(120) default 'col demno',
	correo varchar(100),
	id_rol varchar(64) not null,
	fechacreacion DATETIME2 default CURRENT_TIMESTAMP,
	estado bit,
	constraint fk_rl foreign key (id_rol) references rolusuario(id_role)
)
go
create table cuenta(
	id_cuenta varchar(120) not null,
	id_usuario varchar(120) not null,
	u_name varchar(50) default 'usuario',
	u_pass varchar(50) default '0x202CB962AC59075B964B07152D234B70',
	u_state bit,
	u_registro DATETIME2 default CURRENT_TIMESTAMP,
	constraint pk_cuenta primary key(id_cuenta,id_usuario),
	constraint fk_user foreign key (id_usuario) references usuarios(idusuario)
);

go
create table telefono(
	idtelefono varchar(120) primary key,
	telefono varchar(20),
	idusuario varchar(120) foreign key references usuarios(idusuario)
)


go
create table categorias(
	idcategoria varchar(120) primary key,
	nombre varchar(100),
	descripcion varchar(300)
)
go
create table paquetes(
	idpaquete varchar(120) primary key,
	nombre varchar(100),
	descripcion varchar(300),
	direccion varchar(200),
	idmunicipio varchar(120) foreign key references municipios(idmunicipio),
	idcategoria varchar(120) foreign key references categorias(idcategoria),
	img varchar(500)
)

go 

create table paqueteCalificacion(
	id_calificacion varchar(120) not null,
	id_usuario varchar(120) not null foreign key references usuarios(idusuario),
	id_paquete varchar(120) not null foreign key references paquetes(idpaquete),
	nota bit default 0,
	fecha DATETIME2 default CURRENT_TIMESTAMP,
	constraint pk_cal primary key (id_calificacion,id_usuario)
);

go
create table paquetesdisponible(
	idpaqueted varchar(120) primary key,
	idpaquete varchar(120) foreign key references paquetes(idpaquete),
	precio money,
	cupos_disp int,
	cuposllenos int,
	fechainicial datetime,
	fechafinal datetime,
	estado bit
)
go
create table adicionales(
	idadicional varchar(120) primary key,
	nombre varchar(100) ,
	descripcion varchar(200),
	precio money,
)
go
create table adicionalesdisponible(
	idadicionald varchar(120) primary key,
	idpaqueted varchar(120) foreign key references paquetesdisponible(idpaqueted),
	idadicional varchar(120) foreign key references adicionales(idadicional)
)

go
create table formapago(
	idformapago varchar(120) primary key,
	metodopago varchar(50),
	descripcion varchar(150),
	estado bit
)
go
create table encabezado(
	idencabezado varchar(120) primary key,
	idcuenta varchar(120) not null,
	idformapago varchar(120) foreign key references formapago(idformapago),
	descuento money,
	monto money,
	fecha DATETIME2 default CURRENT_TIMESTAMP,

	constraint fk_uen foreign key (idcuenta) references usuarios(idusuario)
)
go
create table detalle(
	iddetalle varchar(120) primary key,
	idencabezado varchar(120) foreign key references encabezado(idencabezado),
	idpaqueted varchar(120) foreign key references paquetesdisponible(idpaqueted),
	precio money,
	descuento money,
	monto money,
	cupos int
)
go
create table personasextras(
	idagregado varchar(120) primary key,
	nombre varchar(100),
	apellido varchar(100),
	n_doc varchar(50),
	edad tinyint default 18,
	iddetalle varchar(120) foreign key references detalle(iddetalle),
	idcuenta varchar(120) not null,

	constraint fk_extras foreign key (idcuenta) references usuarios(idusuario)
)
go	

--------------------------procedimientos almacenados--------------------------------------------------------------
--funcionamiento general de todos los procedimientos

--procedimeinto con prefijo Ins es para insertar
--procedimeinto con prefijo Re es para retornar todos los dato
--procedimeinto con prefijo Aux es para retornar un dato que se quiera actualziar
--procedimeinto con prefijo Actu es para actualziar los datos
--procedimeinto con prefijo Borr es para borrar

--devuelve 0 si ocurrio algun error de transaccion
--devuelve 1 si todo salio bien
--devuelve -1 si ocurrio algun error de logica


--------------------------categorias------------------------------------------------------------------------------

	create proc SP_InsCategorias
	@id as varchar(120),
	@nombre as varchar(100),
	@descripcion as varchar(300)
	as
	begin
		if(exists(select * from categorias where idcategoria=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 
					begin try
						insert into categorias values (@id,@nombre,@descripcion)
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsCategorias '1','categoria1','descripcion1'
exec SP_InsCategorias '2','categoria2','descripcion2'
exec SP_InsCategorias '3','categoria3','descripcion3'
exec SP_InsCategorias '4','categoria4','descripcion4'
exec SP_InsCategorias '5','categoria5','descripcion5'
*/

go
	--vista categorias
	create view vcategorias
	as
	select * from categorias
	--select * from vcategorias
go
	create proc SP_ReCategorias
	as
	begin
		select * from vcategorias
	end
	--exec SP_ReCategorias 
go
	create proc SP_AuxCategorias
	@id as varchar(120)
	as
	begin
		select * from vcategorias where idcategoria=@id
	end
	--exec SP_AuxCategorias '1'
go
	create proc SP_ActuCategorias
	@id as varchar(120),
	@nom as varchar(100),
	@des as varchar(300)
	as
	begin
		begin tran
			begin try
				update categorias
				set nombre=@nom,
					descripcion=@des
				where idcategoria=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuCategorias '1','categoria111','descripcion111'
	--select * from vcategorias 
go
	create proc SP_BorrCategorias
	@id as varchar(120)
	as
	begin
		if(exists(select * from categorias where idcategoria=@id))
			begin try
				delete categorias where idcategoria=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
	end
	--exec SP_BorrCategorias '1'
go


--------------------------departamentos------------------------------------------------------------------------------
	create proc SP_InsDepartamentos
	@id as varchar(120),
	@nombre as varchar(100)
	as
	begin
		if(exists(select * from departamentos where iddepartamento=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 
					begin try
						insert into departamentos values (@id,@nombre)
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsDepartamentos '1','departamento1'
exec SP_InsDepartamentos '2','departamento2'
exec SP_InsDepartamentos '3','departamento3'
exec SP_InsDepartamentos '4','departamento4'
exec SP_InsDepartamentos '5','departamento5'
*/

go
	--vista departamentos
	create view vdepartamentos
	as
	select * from departamentos
	--select * from vdepartamentos
go
	create proc SP_ReDepartamentos
	as
	begin
		select * from vdepartamentos
	end
	--exec SP_ReDepartamentos 
go
	create proc SP_AuxDepartamentos
	@id as varchar(120)
	as
	begin
		select * from vdepartamentos where iddepartamento=@id
	end
	--exec SP_AuxDepartamentos '1'
go
	create proc SP_ActuDepartamentos
	@id as varchar(120),
	@nom as varchar(100)
	as
	begin
		begin tran
			begin try
				update departamentos
				set nombre=@nom
				where iddepartamento=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuDepartamentos '1','departamento11100000000000000000000000000000000000000000000000000000000000000'
	--select * from vdepartamentos 
go
	create proc SP_BorrDepartamentos
	@id as varchar(120)
	as
	begin
		if(exists(select * from departamentos where iddepartamento=@id))
			begin try
				delete departamentos where iddepartamento=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
	end
	--exec SP_BorrDepartamentos '1'
	--select * from vdepartamentos 
go

--------------------------municipios------------------------------------------------------------------------------
	create proc SP_InsMunicipios
	@id as varchar(120),
	@nombre as varchar(100),
	@idd as varchar(120)
	as
	begin
		if(exists(select * from municipios where idmunicipio=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 
					begin try
						insert into municipios values (@id,@nombre,@idd)
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsMunicipios '1','municipio1','1'
exec SP_InsMunicipios '2','municipio2','1'
exec SP_InsMunicipios '3','municipio3','2'
exec SP_InsMunicipios '4','municipio4','2'
exec SP_InsMunicipios '5','municipio5','3'
*/

go
	--vista municipios
	create view vmunicipios
	as
	select * from municipios
	--select * from vmunicipios
go
	create proc SP_ReMunicipios
	as
	begin
		select * from vmunicipios
	end
	--exec SP_ReMunicipios 
go
	create proc SP_AuxMunicipios
	@id as varchar(120)
	as
	begin
		select * from vmunicipios where idmunicipio=@id
	end
	--exec SP_AuxMunicipios '1'
go
	create proc SP_ActuMunicipios
	@id as varchar(120),
	@nom as varchar(100),
	@idd as varchar(120)
	as
	begin
		begin tran
			begin try
				update municipios
				set nombre=@nom,
					idmunicipio=@idd
				where idmunicipio=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuMunicipios '1','municipio111','2'
	--select * from vmunicipios 
go
	create proc SP_BorrMunicipios
	@id as varchar(120)
	as
	begin
		if(exists(select * from municipios where idmunicipio=@id))
			begin try
				delete municipios where idmunicipio=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrMunicipios '1'
	--select * from vmunicipios 

go
--------------------------rolusuario------------------------------------------------------------------------------
	create proc SP_InsRolUsuario
	@id as varchar(64),
	@r_name as varchar(50)
	as
	begin
		if(exists(select * from rolusuario where id_role=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 
					begin try
						insert into rolusuario(id_role,r_name) values (@id,@r_name)
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsRolUsuario '1','rol1','1'
exec SP_InsRolUsuario '2','rol2','1'
exec SP_InsRolUsuario '3','rol3','2'
exec SP_InsRolUsuario '4','rol4','2'
exec SP_InsRolUsuario '5','rol5','3'
*/

go
	--vista rolusuario
	create view vrolusuario
	as
	select * from rolusuario
	--select * from vrolusuario
go
	create proc SP_ReRolUsuario
	as
	begin
		select * from vrolusuario
	end
	--exec SP_ReRolUsuario 
go
	create proc SP_AuxRolUsuario
	@id as varchar(64)
	as
	begin
		select * from vrolusuario where id_role=@id
	end
	--exec SP_AuxRolUsuario '1'
go
	create proc SP_ActuRolUsuario
	@id as varchar(64),
	@nom as varchar(50)
	as
	begin
		begin tran
			begin try
				update rolusuario
				set r_name=@nom
				where id_role=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuRolUsuario '1','rol111'
	--select * from vrolusuario 
go
	create proc SP_BorrRolUsuario
	@id as varchar(64)
	as
	begin
		if(exists(select * from rolusuario where id_role=@id))
			begin try
				delete rolusuario where id_role=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrRolUsuario '1'
	--select * from vrolusuario
go
--------------------------adicionales------------------------------------------------------------------------------
	create proc SP_InsAdicionales
	@id as varchar(120),
	@nom as varchar(100),
	@desc as varchar(200),
	@precio money
	as
	begin
		if(exists(select * from adicionales where idadicional=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 
					begin try
						insert into adicionales values (@id,@nom,@desc,@precio)
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsAdicionales '1','adicional1','descripcion1',1.6
exec SP_InsAdicionales '2','adicional2','descripcion2',1.5
exec SP_InsAdicionales '3','adicional3','descripcion3',1.7
exec SP_InsAdicionales '4','adicional4','descripcion4',1.8
exec SP_InsAdicionales '5','adicional5','descripcion5',1.9
*/

go
	--vista adicionales
	create view vadicionales
	as
	select * from adicionales
	--select * from vadicionales
go
	create proc SP_ReAdicionales
	as
	begin
		select * from vadicionales
	end
	--exec SP_ReAdicionales 
go
	create proc SP_AuxAdicionales
	@id as varchar(120)
	as
	begin
		select * from vadicionales where idadicional=@id
	end
	--exec SP_AuxAdicionales '1'
go
	create proc SP_ActuAdicionales
	@id as varchar(120),
	@nom as varchar(100),
	@desc as varchar(200),
	@precio money
	as
	begin
		begin tran
			begin try
				update adicionales
				set nombre=@nom,
				descripcion=@desc,
				precio=@precio
				where idadicional=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuAdicionales '1','adicional111','descripcion111',3.5
	--select * from vadicionales 
go
	create proc SP_BorrAdicionales
	@id as varchar(120)
	as
	begin
		if(exists(select * from adicionales where idadicional=@id))
			begin try
				delete adicionales where idadicional=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrAdicionales '1'
	--select * from vadicionales 
go
--------------------------formapago------------------------------------------------------------------------------
	create proc SP_InsFormapago
	@id as varchar(120),
	@met as varchar(50),
	@desc as varchar(150),
	@est bit
	as
	begin
		if(exists(select * from formapago where idformapago=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 
					begin try
						insert into formapago values (@id,@met,@desc,@est)
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsFormapago '1','forma1','descripcion1',1
exec SP_InsFormapago '2','forma2','descripcion2',1
exec SP_InsFormapago '3','forma3','descripcion3',0
exec SP_InsFormapago '4','forma4','descripcion4',1
exec SP_InsFormapago '5','forma5','descripcion5',1
*/

go
	--vista formapago
	create view vformapago
	as
	select * from formapago
	--select * from vformapago
go
	create proc SP_ReFormapago
	as
	begin
		select * from vformapago
	end
	--exec SP_ReFormapago 
go
	create proc SP_AuxFormapago
	@id as varchar(120)
	as
	begin
		select * from vformapago where idformapago=@id
	end
	--exec SP_AuxFormapago '1'
go
	create proc SP_ActuFormapago
	@id as varchar(120),
	@met as varchar(50),
	@desc as varchar(150),
	@est bit
	as
	begin
		begin tran
			begin try
				update formapago
				set metodopago=@met,
				descripcion=@desc,
				estado=@est
				where idformapago=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuFormapago '1','forma111','descripcion111',0
	--select * from vformapago 
go
	create proc SP_BorrFormapago
	@id as varchar(120)
	as
	begin
		if(exists(select * from formapago where idformapago=@id))
			begin try
				delete formapago where idformapago=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrFormapago '1'
	--select * from vformapago 
go
--------------------------paquetes------------------------------------------------------------------------------
	create proc SP_InsPaquetes
	@id as varchar(120),
	@nom varchar(100),
	@des varchar(300),
	@dir varchar(200),
	@idmun varchar(120), 
	@idcate varchar(120),
	@img varchar(500)
	as
	begin
		if(exists(select * from paquetes where idpaquete=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 
					begin try
						insert into paquetes values (@id,@nom,@des,@dir,@idmun,@idcate,@img)
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsPaquetes '1','Paquete1','descripcion1','direccion1',1,1,'img1'
exec SP_InsPaquetes '2','Paquete2','descripcion2','direccion2',1,1,'img2'
exec SP_InsPaquetes '3','Paquete3','descripcion3','direccion3',2,2,'img3'
exec SP_InsPaquetes '4','Paquete4','descripcion4','direccion4',2,2,'img4'
exec SP_InsPaquetes '5','Paquete5','descripcion5','direccion5',3,3,'img5'
*/

go
	--vista paquetes
	create view vpaquetes
	as
	select * from paquetes
	--select * from vpaquetes
go
	create proc SP_RePaquetes
	as
	begin
		select * from vpaquetes
	end
	--exec SP_RePaquetes 
go
	create proc SP_AuxPaquetes
	@id as varchar(120)
	as
	begin
		select * from vpaquetes where idpaquete=@id
	end
	--exec SP_AuxPaquetes '1'
go
	create proc SP_ActuPaquetes
	@id as varchar(120),
	@nom varchar(100),
	@des varchar(300),
	@dir varchar(200),
	@idmun varchar(120), 
	@idcate varchar(120),
	@img varchar(500)
	as
	begin
		begin tran
			begin try
				update paquetes
				set nombre=@nom,
				descripcion=@des,
				direccion=@dir,
				idmunicipio=@idmun,
				idcategoria=@idcate,
				img=@img
				where idpaquete=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuPaquetes '1','Paquete111','descripcion111','direccion111',4,4,'img1111'
	--select * from vpaquetes 
go
	create proc SP_BorrPaquetes
	@id as varchar(120)
	as
	begin
		if(exists(select * from paquetes where idpaquete=@id))
			begin try
				delete paquetes where idpaquete=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrPaquetes '1'
	--select * from vpaquetes  
go
--------------------------usuarios------------------------------------------------------------------------------
	create proc SP_InsUsuarios
	@id as varchar(120),
	@nom varchar(100),
	@apell varchar(100),
	@edad tinyint,
	@tel varchar(15),
	@dir varchar(120),
	@correo varchar(100),
	@id_rol varchar(64),
	@estado bit
	as
	begin
		if(exists(select * from usuarios where idusuario=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 

					begin try
						if(@tel='' and @dir='')
						begin
							insert into usuarios(idusuario,nombre,apellido,edad,
							correo,id_rol,estado) 
							values (@id,@nom,@apell,@edad,
							@correo,@id_rol,@estado)
						end
						else if(@tel='')
						begin 
							insert into usuarios(idusuario,nombre,apellido,edad,
							direccion,correo,id_rol,estado) 
							values (@id,@nom,@apell,@edad,
							@dir,@correo,@id_rol,@estado)
						end
						else if(@dir='')
						begin
							insert into usuarios(idusuario,nombre,apellido,edad,
							telefono,correo,id_rol,estado) 
							values (@id,@nom,@apell,@edad,
							@tel,@correo,@id_rol,@estado)
						end
						else
						begin
							insert into usuarios(idusuario,nombre,apellido,edad,
							telefono,direccion,correo,id_rol,estado) 
							values (@id,@nom,@apell,@edad,
							@tel,@dir,@correo,@id_rol,@estado)
						end
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsUsuarios '1','usuario1','apellido1',18,'1234-5671','direccion1','correo@usiario1.com',1,0
exec SP_InsUsuarios '2','usuario2','apellido2',19,'','direccion2','correo@usiario2.com',2,0
exec SP_InsUsuarios '3','usuario3','apellido3',20,'1234-5673','','correo@usiario3.com',3,1
exec SP_InsUsuarios '4','usuario4','apellido4',21,'','','correo@usiario4.com',4,0
exec SP_InsUsuarios '5','usuario5','apellido5',22,'1234-5675','direccion5','correo@usiario5.com',5,0
*/

go
	--vista usuarios
	create view vusuarios
	as
	select * from usuarios
	--select * from vusuarios
go
	create proc SP_ReUsuarios
	as
	begin
		select * from vusuarios
	end
	--exec SP_ReUsuarios 
go
	create proc SP_AuxUsuarios
	@id as varchar(120)
	as
	begin
		select * from vusuarios where idusuario=@id
	end
	--exec SP_AuxUsuarios '1'
go
	create proc SP_ActuUsuarios
	@id as varchar(120),
	@nom varchar(100),
	@apell varchar(100),
	@edad tinyint,
	@tel varchar(15),
	@dir varchar(120),
	@correo varchar(100),
	@id_rol varchar(64),
	@estado bit
	as
	begin
		begin tran
			begin try
				update usuarios
				set nombre=@nom,
				apellido=@apell,
				edad=@edad,
				telefono=@tel,
				direccion=@dir,
				correo=@correo,
				id_rol=@id_rol,
				estado=@estado
				where idusuario=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuUsuarios '1','usuario111','apellido111',181,'1234-5676','direccion111','correo@usiario111.com',5,1
	--select * from vusuarios 
go
	create proc SP_BorrUsuarios
	@id as varchar(120)
	as
	begin
		if(exists(select * from usuarios where idusuario=@id))
			begin try
				delete usuarios where idusuario=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrUsuarios '1'
	--select * from vusuarios 

go

--------------------------paqueteCalificacion------------------------------------------------------------------------------
	create proc SP_InsPaqueteCalificacion
	@id as varchar(120),
	@idu varchar(120) ,
	@idp varchar(120) ,
	@nota bit
	as
	begin
		if(exists(select * from paqueteCalificacion where id_calificacion=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 

					begin try
						if(@nota='')
						begin
							insert into paqueteCalificacion(id_calificacion,id_usuario,id_paquete)
							values (@id,@idu,@idp)
						end
						else
						begin 
							insert into paqueteCalificacion(id_calificacion,id_usuario,id_paquete,nota)
							values (@id,@idu,@idp,@nota)
						end
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsPaqueteCalificacion '1','1','5',1
exec SP_InsPaqueteCalificacion '2','1','5',''
exec SP_InsPaqueteCalificacion '3','2','4',1
exec SP_InsPaqueteCalificacion '4','2','4',0
exec SP_InsPaqueteCalificacion '5','3','3',1

*/

go
	--vista paqueteCalificacion
	create view vpaqueteCalificacion
	as
	select * from paqueteCalificacion
	--select * from vpaqueteCalificacion
go
	create proc SP_RePaqueteCalificacion
	as
	begin
		select * from vpaqueteCalificacion
	end
	--exec SP_RePaqueteCalificacion 
go
	create proc SP_AuxPaqueteCalificacion
	@id as varchar(120)
	as
	begin
		select * from vpaqueteCalificacion where id_calificacion=@id
	end
	--exec SP_AuxPaqueteCalificacion '1'
go
	create proc SP_ActuPaqueteCalificacion
	@id as varchar(120),
	@idu varchar(120) ,
	@idp varchar(120) ,
	@nota bit
	as
	begin
		begin tran
			begin try
				update paqueteCalificacion
				set id_usuario=@idu,
				id_paquete=@idp,
				nota=@nota
				where id_calificacion=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuPaqueteCalificacion 1,4,4,0
	--select * from vpaqueteCalificacion 
go
	create proc SP_BorrPaqueteCalificacion
	@id as varchar(120)
	as
	begin
		if(exists(select * from paqueteCalificacion where id_calificacion=@id))
			begin try
				delete paqueteCalificacion where id_calificacion=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrPaqueteCalificacion 1
	--select * from vpaqueteCalificacion 
go

--------------------------cuenta------------------------------------------------------------------------------
	create proc SP_InsCuenta
	@id as varchar(120),
	@idu varchar(120) ,
	@uname varchar(50),-- default 'usuario',
	@upass varchar(50),-- default '0x202CB962AC59075B964B07152D234B70',
	@ustate bit
	as
	begin
		if(exists(select * from cuenta where id_cuenta=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 

					begin try
						if(@uname='' and @upass='' )
						begin
							insert into cuenta(id_cuenta,id_usuario,u_state)
							values (@id,@idu,@ustate)
						end
						else if(@uname='')
						begin 
							insert into cuenta(id_cuenta,id_usuario,u_pass,u_state)
							values (@id,@idu,@upass,@ustate)
						end
						else if(@upass='')
						begin 
							insert into cuenta(id_cuenta,id_usuario,u_name,u_state)
							values (@id,@idu,@uname,@ustate)
						end
						else 
						begin 
							insert into cuenta(id_cuenta,id_usuario,u_name,u_pass,u_state)
							values (@id,@idu,@uname,@upass,@ustate)
						end




						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsCuenta 1,1,'nombre1','contra1',1
exec SP_InsCuenta 2,2,'','',0
exec SP_InsCuenta 3,3,'','contra3',1
exec SP_InsCuenta 4,4,nombre4,'',0
exec SP_InsCuenta 5,5,nombre5,contra5,1

*/

go
	--vista cuenta
	create view vcuenta
	as
	select * from cuenta
	--select * from vcuenta
go
	create proc SP_ReCuenta
	as
	begin
		select * from vcuenta
	end
	--exec SP_ReCuenta 
go
	create proc SP_AuxCuenta
	@id as varchar(120)
	as
	begin
		select * from vcuenta where id_cuenta=@id
	end
	--exec SP_AuxCuenta 1
go
	create proc SP_ActuCuenta
	@id as varchar(120),
	@idu varchar(120) ,
	@uname varchar(50),
	@upass varchar(50),
	@ustate bit
	as
	begin
		begin tran
			begin try
				update cuenta
				set id_usuario=@idu,
				u_name=@uname,
				u_pass=@upass,
				u_state=@ustate
				where id_cuenta=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuCuenta 1,2,'nombre1111','contra1111',0
	--select * from vcuenta 
go
	create proc SP_BorrCuenta
	@id as varchar(120)
	as
	begin
		if(exists(select * from cuenta where id_cuenta=@id))
			begin try
				delete cuenta where id_cuenta=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrCuenta '1'
	--select * from vcuenta 
go

--------------------------telefono------------------------------------------------------------------------------
	create proc SP_InsTelefono
	@id as varchar(120),
	@tel varchar(20),
	@idu varchar(120) 
	as
	begin
		if(exists(select * from telefono where idtelefono=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 

					begin try
						insert into telefono
						values (@id,@tel,@idu)
					
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsTelefono 1,'1234-5671',1
exec SP_InsTelefono 2,'1234-5672',2
exec SP_InsTelefono 3,'1234-5673',3
exec SP_InsTelefono 4,'1234-5674',4
exec SP_InsTelefono 5,'1234-5675',5

*/

go
	--vista telefono
	create view vtelefono
	as
	select * from telefono
	--select * from vtelefono
go
	create proc SP_ReTelefono
	as
	begin
		select * from vtelefono
	end
	--exec SP_ReTelefono 
go
	create proc SP_AuxTelefono
	@id as varchar(120)
	as
	begin
		select * from vtelefono where idtelefono=@id
	end
	--exec SP_AuxTelefono 1
go
	create proc SP_ActuTelefono
	@id as varchar(120),
	@tel varchar(20),
	@idu varchar(120) 
	as
	begin
		begin tran
			begin try
				update telefono
				set	telefono=@tel,
				idusuario=@idu	
				where idtelefono=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuTelefono 1,'1111-1111',2
	--select * from vtelefono 
go
	create proc SP_BorrTelefono
	@id as varchar(120)
	as
	begin
		if(exists(select * from telefono where idtelefono=@id))
			begin try
				delete telefono where idtelefono=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrTelefono '1'
	--select * from vtelefono
go
--------------------------paquetesdisponible------------------------------------------------------------------------------
	create proc SP_InsPaquetesDisponible
	@id as varchar(120),
	@idp varchar(120),
	@precio money,
	@cdisp int,
	@cllenos int,
	@finicial datetime,
	@ffinal datetime,
	@estado bit
	as
	begin
		if(exists(select * from paquetesdisponible where idpaqueted=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 

					begin try
						insert into paquetesdisponible
						values (@id,@idp,@precio,@cdisp,@cllenos,@finicial,@ffinal,@estado)
					
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsPaquetesDisponible 1,1,1.6,5,0,'2023-4-8','2023-4-10',1
exec SP_InsPaquetesDisponible 2,2,1.7,10,0,'2023-4-8','2023-4-11',0
exec SP_InsPaquetesDisponible 3,3,1.8,15,0,'2023-4-8','2023-4-12',1
exec SP_InsPaquetesDisponible 4,4,1.9,20,0,'2023-4-8','2023-4-13',0
exec SP_InsPaquetesDisponible 5,5,2.1,25,0,'2023-4-8','2023-4-14',1


*/

go
	--vista paquetesdisponible
	create view vpaquetesdisponible
	as
	select * from paquetesdisponible
	--select * from vpaquetesdisponible
go
	create proc SP_RePaquetesDisponible
	as
	begin
		select * from vpaquetesdisponible
	end
	--exec SP_RePaquetesDisponible 
go
	create proc SP_AuxPaquetesDisponible
	@id as varchar(120)
	as
	begin
		select * from vpaquetesdisponible where idpaqueted=@id
	end
	--exec SP_AuxPaquetesDisponible 1
go
	create proc SP_ActuPaquetesDisponible
	@id as varchar(120),
	@idp varchar(120),
	@precio money,
	@cdisp int,
	@cllenos int,
	@finicial datetime,
	@ffinal datetime,
	@estado bit
	as
	begin
		begin tran
			begin try
				update paquetesdisponible
				set precio=@precio,
				cupos_disp=@cdisp,
				cuposllenos=@cllenos,
				fechainicial=@finicial,
				fechafinal=@ffinal,
				estado=@estado
				where idpaquete=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuPaquetesDisponible 1,2,4.6,50,1,'2023-4-20','2023-4-30',0
	--select * from vpaquetesdisponible 
go
	create proc SP_BorrPaquetesDisponible
	@id as varchar(120)
	as
	begin
		if(exists(select * from paquetesdisponible where idpaqueted=@id))
			begin try
				delete paquetesdisponible where idpaqueted=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrPaquetesDisponible '1'
	--select * from vpaquetesdisponible 
go
--------------------------encabezado------------------------------------------------------------------------------
	create proc SP_InsEncabezado
	@id as varchar(120),
	@idc varchar(120) ,
	@idfpg varchar(120) ,
	@descuento money,
	@monto money
	as
	begin
		if(exists(select * from encabezado where idencabezado=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 

					begin try
						insert into encabezado (idencabezado,idcuenta,idformapago,descuento,monto)
						values (@id,@idc,@idfpg,@descuento,@monto)
					
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsEncabezado 1,1,1,2.5,6.75
exec SP_InsEncabezado 2,2,2,3.5,7.75
exec SP_InsEncabezado 3,3,3,4.5,8.75
exec SP_InsEncabezado 4,4,4,5.5,9.75
exec SP_InsEncabezado 5,5,5,6.5,10.75



*/

go
	--vista encabezado
	create view vencabezado
	as
	select * from encabezado
	--select * from vencabezado
go
	create proc SP_ReEncabezado
	as
	begin
		select * from vencabezado
	end
	--exec SP_ReEncabezado 
go
	create proc SP_AuxEncabezado
	@id as varchar(120)
	as
	begin
		select * from vencabezado where idencabezado=@id
	end
	--exec SP_AuxEncabezado 1
go
	create proc SP_ActuEncabezado
	@id as varchar(120),
	@idc varchar(120) ,
	@idfpg varchar(120) ,
	@descuento money,
	@monto money
	as
	begin
		begin tran
			begin try
				update encabezado
				set idcuenta=@idc,
				idformapago=@idfpg,
				descuento=@descuento,
				monto=@monto
				where idcuenta=@id

				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuEncabezado 1,2,2,22.5,66.75
	--select * from vencabezado 
go
	create proc SP_BorrEncabezado
	@id as varchar(120)
	as
	begin
		if(exists(select * from encabezado where idencabezado=@id))
			begin try
				delete encabezado where idencabezado=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrEncabezado '1'
	--select * from vencabezado
go

--------------------------detalle------------------------------------------------------------------------------
	create proc SP_InsDetalle
	@id as varchar(120),
	@idenc varchar(120) ,
	@idpd varchar(120) ,
	@precio money,
	@descuento money,
	@monto money,
	@cupos int
	as
	begin
		if(exists(select * from detalle where iddetalle=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 

					begin try
						insert into detalle
						values (@id,@idenc,@idpd,@precio,@descuento,@monto,@cupos)
					
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsDetalle 1,1,1,1.5,2.5,3.5,1
exec SP_InsDetalle 2,2,2,1.6,2.6,3.6,2
exec SP_InsDetalle 3,3,3,1.7,2.7,3.7,3
exec SP_InsDetalle 4,4,4,1.8,2.8,3.8,4
exec SP_InsDetalle 5,5,5,1.9,2.9,3.9,5


*/

go
	--vista detalle
	create view vdetalle
	as
	select * from detalle
	--select * from vdetalle
go
	create proc SP_ReDetalle
	as
	begin
		select * from vdetalle
	end
	--exec SP_ReDetalle 
go
	create proc SP_AuxDetalle
	@id as varchar(120)
	as
	begin
		select * from vdetalle where iddetalle=@id
	end
	--exec SP_AuxDetalle 1
go
	create proc SP_ActuDetalle
	@id as varchar(120),
	@idenc varchar(120) ,
	@idpd varchar(120) ,
	@precio money,
	@descuento money,
	@monto money,
	@cupos int
	as
	begin
		begin tran
			begin try
				update detalle
				set idencabezado=@idenc,
				idpaqueted=@idpd,
				precio=@precio,
				descuento=@descuento,
				monto=@monto,
				cupos=@cupos
				where iddetalle=@id

				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuDetalle 1,2,2,20.5,20.5,30.5,10
	--select * from vdetalle 
go
	create proc SP_BorrDetalle
	@id as varchar(120)
	as
	begin
		if(exists(select * from detalle where iddetalle=@id))
			begin try
				delete detalle where iddetalle=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrDetalle '1'
	--select * from vdetalle 
go

--------------------------adicionalesdisponible------------------------------------------------------------------------------
	create proc SP_InsAdicionalesDisponible
	@id as varchar(120),
	@idpd varchar(120) ,
	@idad varchar(120) 
	as
	begin
		if(exists(select * from adicionalesdisponible where idadicionald=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 

					begin try
						insert into adicionalesdisponible
						values (@id,@idpd,@idad)
					
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsAdicionalesDisponible 1,1,1
exec SP_InsAdicionalesDisponible 2,2,2
exec SP_InsAdicionalesDisponible 3,3,3
exec SP_InsAdicionalesDisponible 4,4,4
exec SP_InsAdicionalesDisponible 5,5,5


*/

go
	--vista adicionalesdisponible
	create view vadicionalesdisponible
	as
	select * from adicionalesdisponible
	--select * from vadicionalesdisponible
go
	create proc SP_ReAdicionalesDisponible
	as
	begin
		select * from vadicionalesdisponible
	end
	--exec SP_ReAdicionalesDisponible 
go
	create proc SP_AuxAdicionalesDisponible
	@id as varchar(120)
	as
	begin
		select * from vadicionalesdisponible where idadicionald=@id
	end
	--exec SP_AuxAdicionalesDisponible 1
go
	create proc SP_ActuAdicionalesDisponible
	@id as varchar(120),
	@idpd varchar(120) ,
	@idad varchar(120) 
	as
	begin
		begin tran
			begin try
				update adicionalesdisponible
				set idpaqueted=@idpd,
				idadicional=@idad
				where idadicionald=@id
				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuAdicionalesDisponible 1,2,2
	--select * from vadicionalesdisponible 
go
	create proc SP_BorrAdicionalesDisponible
	@id as varchar(120)
	as
	begin
		if(exists(select * from adicionalesdisponible where idadicionald=@id))
			begin try
				delete adicionalesdisponible where idadicionald=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrAdicionalesDisponible '1'
	--select * from vadicionalesdisponible
go

--------------------------personasextras------------------------------------------------------------------------------
	create proc SP_InsPersonasExtras
	@id as varchar(120),
	@nombre varchar(100),
	@apellido varchar(100),
	@ndoc varchar(50),
	@edad tinyint ,
	@iddet varchar(120) ,
	@idc varchar(120)
	as
	begin
		if(exists(select * from personasextras where idagregado=@id))
			begin
				select '-1' as resp
			end
		else
			begin
				begin tran 

					begin try
						if(@edad='')
						begin
							insert into personasextras(idagregado,nombre,apellido,n_doc,iddetalle,idcuenta)
							values (@id,@nombre,@apellido,@ndoc,@iddet,@idc)
						end
						else
						begin
							insert into personasextras
							values (@id,@nombre,@apellido,@ndoc,@edad,@iddet,@idc)
						end
					
					
						if(@id='')
							begin 
								rollback
								select '-1' as resp
							end
						else
							begin
								commit
								select '1' as resp
							end
					end try
					begin catch
						rollback
						select @@ERROR as resp
					end catch
					
			end
	end
/*
prueba
exec SP_InsPersonasExtras 1,'nombre1','apellido1','doc1',23,1,1
exec SP_InsPersonasExtras 2,'nombre2','apellido2','doc2','',2,2
exec SP_InsPersonasExtras 3,'nombre3','apellido3','doc3',25,3,3
exec SP_InsPersonasExtras 4,'nombre4','apellido4','doc4',26,4,4
exec SP_InsPersonasExtras 5,'nombre5','apellido5','doc5',27,5,5
*/

go
	--vista personasextras
	create view vpersonasextras
	as
	select * from personasextras
	--select * from vpersonasextras
go
	create proc SP_RePersonasExtras
	as
	begin
		select * from vpersonasextras
	end
	--exec SP_RePersonasExtras 
go
	create proc SP_AuxPersonasExtras
	@id as varchar(120)
	as
	begin
		select * from vpersonasextras where idagregado=@id
	end
	--exec SP_AuxPersonasExtras 1
go
	create proc SP_ActuPersonasExtras
	@id as varchar(120),
	@nombre varchar(100),
	@apellido varchar(100),
	@ndoc varchar(50),
	@edad tinyint ,
	@iddet varchar(120) ,
	@idc varchar(120)
	as
	begin
		begin tran
			begin try
				update personasextras
				set nombre=@nombre,
				apellido=@apellido,
				n_doc=@ndoc,
				edad=@edad,
				iddetalle=@iddet,
				idcuenta=@idc
				where idagregado=@id
		

				if(@id='')
					begin 
						rollback 
						select '-1' as resp
					end
				else
					begin
						commit
						select '1' as resp
					end
			end try
			begin catch
				rollback
				select @@ERROR as resp
			end catch
	end
	--exec SP_ActuPersonasExtras 1,'nombre1111','apellido1111','doc1111',230,2,2
	--select * from vpersonasextras 
go
	create proc SP_BorrPersonasExtras
	@id as varchar(120)
	as
	begin
		if(exists(select * from personasextras where idagregado=@id))
			begin try
				delete personasextras where idagregado=@id
				select '1' as resp
			end try
			begin catch
				select @@ERROR as resp
			end catch
		else
			select '-1' as resp
 
	end
	--exec SP_BorrPersonasExtras '1'
	--select * from vpersonasextras 