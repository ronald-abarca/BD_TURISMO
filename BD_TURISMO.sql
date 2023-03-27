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
	nombre varchar(200) ,
	descripcion varchar(100),
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
	


