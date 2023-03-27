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
)
go
create table usuarios(
	idusuario varchar(120) primary key,
	nombre varchar(100),
	apellido varchar(100),
	correo varchar(100),
	contrasegna varchar(120),
	fechacreacion datetime,
	estado bit
)
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
	idmunicipio varchar(120) foreign key references municipios(idmunicipio),
	idcategoria varchar(120) foreign key references categorias(idcategoria),
	img varchar(500)
)
go
create table paquetesdisponible(
	idpaqueted varchar(120) primary key,
	idpaquete varchar(120) foreign key references paquetes(idpaquete),
	precio money,
	cupos int,
	cuposllenos int,
	fechainicial datetime,
	fechafinal datetime,
	estado bit
)
go
create table adicionales(
	idadicional varchar(120) primary key,
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
create table cliente(
	idcliente varchar(120) primary key,
	nombre varchar(100),
	apellido varchar(100),
	idtelefono varchar(120) foreign key references telefono(idtelefono),
	correo varchar(100),
	fechacreacion datetime,
	estado bit
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
	idcliente varchar(120) foreign key references cliente(idcliente),
	idformapago varchar(120) foreign key references formapago(idformapago),
	descuento money,
	monto money,
	fecha datetime
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
	iddetalle varchar(120) foreign key references detalle(iddetalle),
	idcliente varchar(120) foreign key references cliente(idcliente)
)
	

