create database PreguntasRespuestasDB
go

use PreguntasRespuestasDB
go

CREATE TABLE Usuarios (
    UsuarioID int identity primary key,
    NombreUsuario nvarchar(50) not null unique,
    Clave nvarchar(255) not null,
	Rol varchar(50) default 'usuario'
);
go

CREATE TABLE Preguntas (
    PreguntaID int identity primary key,
    UsuarioID int not null,
    Titulo nvarchar(255) not null,
    FechaCreacion datetime default getdate(),
    Estado bit default 1,
    foreign key (UsuarioID) references Usuarios(UsuarioID)
);
go

CREATE TABLE Respuestas (
    RespuestaID int identity primary key,
    PreguntaID int not null,
    UsuarioID int not null,
    Contenido nvarchar(max) not null,
    FechaCreacion datetime default getdate(),
    foreign key (PreguntaID) references Preguntas(PreguntaID),
    foreign key (UsuarioID) references Usuarios(UsuarioID)
);
go

--inicio presediminetos

create procedure sp_RegistrarUsuario(
@NombreUsuario varchar(100),
@Clave nvarchar(500),
@Registro bit output,
@Mensaje nvarchar(100) output
)
as
begin
	if (not exists(select NombreUsuario from Usuarios where NombreUsuario = @NombreUsuario))
	begin
		insert into Usuarios(NombreUsuario,Clave) values (@NombreUsuario,@Clave)
		set @Registro = 1
		set @mensaje = 'Usuario registrado'
	end
	else
	begin
		set @Registro = 0
		set @Mensaje = 'Usuario ya existe'
	end
end
go

create procedure sp_ValidarUsuario
    @NombreUsuario nvarchar(100),
    @Clave nvarchar(500)
as
begin
    if exists (select 1 from usuarios where NombreUsuario = @NombreUsuario and Clave = @Clave)
    begin
        select UsuarioID, NombreUsuario, Rol 
        from usuarios 
        where NombreUsuario = @NombreUsuario and Clave = @Clave;
    end
    else
    begin
        select null as UsuarioID, null as NombreUsuario, null as Rol;
    end
end

go


create procedure sp_GuardarPregunta
    @UsuarioID int,
    @Titulo nvarchar(255),
    @Mensaje nvarchar(255) output  
as
begin

    insert into preguntas (UsuarioID, Titulo)
    values (@UsuarioID, @Titulo); 

    if @@rowcount > 0
    begin
        set @Mensaje = 'Pregunta publicada correctamente.';
    end
    else
    begin
        set @Mensaje = 'Error al guardar la pregunta.';
    end
end;
go


create procedure sp_ActualizarEstadoPregunta
    @PreguntaID int,
    @NuevoEstado bit,
    @Mensaje nvarchar(255) output
as
begin
    
    update preguntas
    set estado = @NuevoEstado
    where PreguntaID = @PreguntaID;

   
    if @@rowcount > 0
    begin
        
        set @Mensaje = 'Estado de la pregunta actualizado correctamente.';
    end
    else
    begin
       
        set @Mensaje = 'Error al actualizar el estado de la pregunta.';
    end
end;
go




create procedure sp_InsertarRespuesta
    @PreguntaID int,
    @UsuarioID int,
    @Contenido nvarchar(max),
    @Mensaje nvarchar(255) output
as
begin

    if exists (select 1 from preguntas where PreguntaID = @PreguntaID and estado = 1)
    begin
        
        insert into respuestas (PreguntaID, UsuarioID, Contenido, FechaCreacion)
        values (@PreguntaID, @UsuarioID, @Contenido, getdate());
        
        set @Mensaje = 'Respuesta publicada correctamente.';
    end
end
go



--fin procedimientos

declare @registrado bit, @mensaje varchar(100)

exec sp_RegistrarUsuario 'usuario1','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',@registrado output,@mensaje output

select @registrado
select @mensaje
go

