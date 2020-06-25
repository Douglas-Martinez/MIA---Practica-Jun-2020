/*******************************
* DOUGLAS OMAR ARREOLA MARTINEZ*
* CARNE: 201603168             *
********************************/

CREATE DATABASE prueba;

/*
** 1. Generar el script que crea cada una de las tablas que conforman la base de datos propuesta por el Comité Olímpico.
*/
--1. PROFESION
CREATE TABLE profesion (
    cod_prof INTEGER NOT NULL,
    nombre   VARCHAR(50) UNIQUE NOT NULL,

    PRIMARY KEY (cod_prof)
);

--2. PAIS
CREATE TABLE pais (
    cod_pais  INTEGER NOT NULL,
    nombre    VARCHAR(50) UNIQUE NOT NULL,

    PRIMARY KEY (cod_pais)
);

--3. PUESTO
CREATE TABLE puesto (
    cod_puesto INTEGER NOT NULL,
    nombre     VARCHAR(50) UNIQUE NOT NULL, 

    PRIMARY KEY (cod_puesto)
);

--4. DEPARTAMENTO
CREATE TABLE departamento (
    cod_depto  INTEGER NOT NULL,
    nombre     VARCHAR(50) UNIQUE NOT NULL,

    PRIMARY KEY (cod_depto)
);

--5. MIEMBRO
CREATE TABLE miembro (
    cod_miembro         INTEGER NOT NULL,
    nombre              VARCHAR(100) NOT NULL,
    apellido            VARCHAR(100) NOT NULL,
    edad                INTEGER NOT NULL,
    telefono            INTEGER,
    residencia          VARCHAR(100),
    PAIS_cod_pais       INTEGER NOT NULL,
    PROFESION_cod_prof  INTEGER NOT NULL,

    PRIMARY KEY (cod_miembro),

    FOREIGN KEY (PAIS_cod_pais) REFERENCES pais (cod_pais) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PROFESION_cod_prof) REFERENCES profesion (cod_prof) ON DELETE CASCADE ON UPDATE CASCADE
);

--6. PUESTO_MIEMBRO
CREATE TABLE puesto_miembro (
    MIEMBRO_cod_miembro     INTEGER  NOT NULL,
    PUESTO_cod_puesto       INTEGER  NOT NULL,
    DEPARTAMENTO_cod_depto  INTEGER  NOT NULL,
    fecha_inicio            DATE NOT NULL,
    fecha_fin               DATE,

    PRIMARY KEY (MIEMBRO_cod_miembro, PUESTO_cod_puesto, DEPARTAMENTO_cod_depto),

    FOREIGN KEY (MIEMBRO_cod_miembro) REFERENCES miembro (cod_miembro) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PUESTO_cod_puesto) REFERENCES puesto (cod_puesto) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (DEPARTAMENTO_cod_depto) REFERENCES departamento (cod_depto) ON DELETE CASCADE ON UPDATE CASCADE
);

--7. TIPO_MEDALLA
CREATE TABLE tipo_medalla (
    cod_tipo  INTEGER NOT NULL,
    medalla   VARCHAR(20) UNIQUE NOT NULL,

    PRIMARY KEY(cod_tipo)
);

--8. MEDALLERO
CREATE TABLE medallero (
    PAIS_cod_pais          INTEGER NOT NULL,
    cantidad_medallas      INTEGER NOT NULL,
    TIPO_MEDALLA_cod_tipo  INTEGER NOT NULL,

    PRIMARY KEY ( PAIS_cod_pais, TIPO_MEDALLA_cod_tipo ),

    FOREIGN KEY ( PAIS_cod_pais ) REFERENCES pais ( cod_pais ) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY ( TIPO_MEDALLA_cod_tipo ) REFERENCES tipo_medalla ( cod_tipo ) ON DELETE CASCADE ON UPDATE CASCADE
);

--9. DISCIPLINA
CREATE TABLE disciplina (
    cod_disciplina  INTEGER NOT NULL,
    nombre          VARCHAR(50) NOT NULL,
    descripcion     VARCHAR(150),

    PRIMARY KEY (cod_disciplina)
);

--10. ATLETA
CREATE TABLE atleta (
    cod_atleta                 INTEGER NOT NULL,
    nombre                     VARCHAR(50) NOT NULL,
    apellido                   VARCHAR(50) NOT NULL,
    edad                       INTEGER NOT NULL,
    participaciones            VARCHAR(100) NOT NULL,
    DISCIPLINA_cod_disciplina  INTEGER NOT NULL,
    PAIS_cod_pais              INTEGER NOT NULL,

    PRIMARY KEY ( cod_atleta ),

    FOREIGN KEY ( DISCIPLINA_cod_disciplina ) REFERENCES disciplina ( cod_disciplina ) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY ( PAIS_cod_pais ) REFERENCES pais ( cod_pais ) ON DELETE CASCADE ON UPDATE CASCADE
);

--11. CATEGORIA
CREATE TABLE categoria (
    cod_categoria  INTEGER NOT NULL,
    categoria      VARCHAR(50) NOT NULL,

    PRIMARY KEY (cod_categoria)
);

--12. TIPO_PARTICIPACION
CREATE TABLE tipo_participacion (
    cod_participacion   INTEGER NOT NULL,
    tipo_participacion  VARCHAR(100) NOT NULL,

    PRIMARY KEY ( cod_participacion )
);

--13. EVENTO
CREATE TABLE evento (
    cod_evento                            INTEGER NOT NULL,
    fecha                                 DATE NOT NULL,
    ubicacion                             VARCHAR(50) NOT NULL,
    hora                                  TIME NOT NULL,
    DISCIPLINA_cod_disciplina             INTEGER NOT NULL, 
    TIPO_PARTICIPACION_cod_participacion  INTEGER NOT NULL,
    CATEGORIA_cod_categoria               INTEGER NOT NULL,

    PRIMARY KEY ( cod_evento ),

    FOREIGN KEY ( DISCIPLINA_cod_disciplina ) REFERENCES disciplina ( cod_disciplina ) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY ( TIPO_PARTICIPACION_cod_participacion ) REFERENCES tipo_participacion ( cod_participacion ) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY ( CATEGORIA_cod_categoria ) REFERENCES categoria ( cod_categoria ) ON DELETE CASCADE ON UPDATE CASCADE
);

--14. EVENTO_ATLETA
CREATE TABLE evento_atleta (
    ATLETA_cod_atleta  INTEGER NOT NULL,
    EVENTO_cod_evento  INTEGER NOT NULL,

    PRIMARY KEY ( ATLETA_cod_atleta, EVENTO_cod_evento ),

    FOREIGN KEY ( ATLETA_cod_atleta ) REFERENCES atleta ( cod_atleta ) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY ( EVENTO_cod_evento ) REFERENCES evento ( cod_evento ) ON DELETE CASCADE ON UPDATE CASCADE
);

--15. TELEVISORA
CREATE TABLE televisora (
    cod_televisora  INTEGER NOT NULL,
    nombre          VARCHAR(50) NOT NULL,

    PRIMARY KEY ( cod_televisora )
);

--16. COSTO_EVENTO
CREATE TABLE costo_evento (
    EVENTO_cod_evento          INTEGER NOT NULL,
    TELEVISORA_cod_televisora  INTEGER NOT NULL,
    tarifa                     NUMERIC NOT NULL,

    PRIMARY KEY ( EVENTO_cod_evento, TELEVISORA_cod_televisora ),

    FOREIGN KEY ( EVENTO_cod_evento ) REFERENCES evento ( cod_evento ) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY ( TELEVISORA_cod_televisora ) REFERENCES televisora ( cod_televisora ) ON DELETE CASCADE ON UPDATE CASCADE
);




/*
** 2. En la tabla “Evento” se decidió que la fecha y hora se trabajaría en una sola columna.
*/
--1. Eliminar las columnas fecha y hora
ALTER TABLE evento DROP COLUMN fecha;
ALTER TABLE evento DROP COLUMN hora;

--2. Crear columna llamada "fecha_hora"
ALTER TABLE evento ADD COLUMN fecha_hora TIMESTAMP NOT NULL;
--ALTER TABLE evento ADD COLUMN fecha_hora TIMESTAMP NOT NULL;




/*
** 3. Todos los eventos de las olimpiadas deben ser programados del 24 de julio de 2020 a partir de las 9:00:00 hasta el 09 de agosto de 2020 hasta las 20:00:00
*/
ALTER TABLE evento ADD CONSTRAINT fecha_hora_check CHECK (
    fecha_hora > '2020-07-24 09:00:00'
    AND fecha_hora < '2020-08-09 20:00:00'
);




/*
** 4. Se decidió que las ubicación de los eventos se registrarán previamente en una tabla y que en la tabla “Evento” sólo se almacenara la llave foránea según el código del registro de la ubicación
*/
--a. Crear tabla llamada "Sede" con los campos: Codigo (Entero y LLave primaria) y Sede (Varchar(50) y obligatorio)
CREATE TABLE sede (
    codigo INTEGER NOT NULL,
    sede VARCHAR(50) NOT NULL,

    PRIMARY KEY ( codigo )
);

--b. Cambiar el tipo de dato de la columna Ubicacion de la tabla evento a Entero
ALTER TABLE evento
    ALTER COLUMN ubicacion TYPE INTEGER USING ubicacion::integer
;

--c. Crear una llave foránea en la columna Ubicación de la tabla Evento y referenciarla a la columna código de la tabla Sede
ALTER TABLE evento 
    ADD CONSTRAINT evento_ubicacion_fkey FOREIGN KEY ( ubicacion ) REFERENCES sede (codigo ON DELETE CASCADE ON UPDATE CASCADE)
;




/*
** 5. Se revisó la información de los miembros que se tienen actualmente y antes de que se ingresen a la base de datos el Comité desea que a los miembros que no tengan número telefónico se le ingrese el número por Default 0 al momento de ser cargados a la base de datos
*/
ALTER TABLE miembro ALTER COLUMN telefono SET DEFAULT 0;




/*
** 6. Generar el script necesario para hacer la inserción de datos a las tablas requeridas
*/
--1. PAIS // SELECT * FROM pais;
INSERT INTO pais (cod_pais,nombre) VALUES
    (1, 'Guatemala'),
    (2, 'Francia'),
    (3, 'Argentina'),
    (4, 'Alemania'),
    (5, 'Italia'),
    (6, 'Brasil'),
    (7, 'Estados Unidos')
;

--2. PROFESION // SELECT * FROM profesion;
INSERT INTO profesion (nombre, cod_prof) VALUES
    ('Medico', 1),
    ('Arquitecto', 2),
    ('Ingeniero', 3),
    ('Secretaria', 4),
    ('Auditor', 5)
;

--3. MIEMBROS // SELECT * FROM miembro;
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, residencia, PAIS_cod_pais, PROFESION_cod_prof) VALUES 
    (1, 'Scott','Mitchell',32,'1092 Highland Drive Manitowoc, WI 54220', 7, 3)
;
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, telefono, residencia, PAIS_cod_pais, PROFESION_cod_prof) VALUES 
    (2, 'Fanette','Poulin',25,25075853,'49, boulevard Aristide Briand 76120 LE GRAND-QUEVILLY', 2, 4)
;
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, residencia, PAIS_cod_pais, PROFESION_cod_prof) VALUES 
    (3, 'Laura','Cunha Silva',55,'Rua Onze, 86 Uberaba-MG', 6, 5)
;
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, telefono, residencia, PAIS_cod_pais, PROFESION_cod_prof) VALUES 
    (4, 'Juan Jose','Lopez',38,36985247,'26 calle 4-10 zona 11', 1, 2),
    (5, 'Arcangela','Panicucci',39,391664921,'Via Santa Teresa, 114 90010-Geraci Siculo PA', 5, 1)
;
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, residencia, PAIS_cod_pais, PROFESION_cod_prof) VALUES 
    (6, 'Jeuel','Villalpando',31,'Acuna de Figeroa 6106 80101 Playa Pascual', 3, 5)
;

--4. DISCIPLINA // SELECT * FROM disciplina;
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES
    (1, 'Atletismo','Saltos de longitud y triples, de altura y con pértiga o garrocha; las pruebas de lanzamiento de martillo, jabalina y disco')
;
INSERT INTO disciplina (cod_disciplina, nombre) VALUES
    (2, 'Badminton'),
    (3, 'Ciclismo')
;
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES
    (4,'Judo','Es un arte marcial que se origino en Japon alrededor de 1880')
;
INSERT INTO disciplina (cod_disciplina, nombre) VALUES
    (5, 'Lucha'),
    (6, 'Tenis de Mesa'),
    (7, 'Boxeo')
;
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES
    (8, 'Natacion','Está presente como deporte en los Juegos desde la primera edición de la era moderna, en Atenas, Grecia, en 1896, donde se disputo en aguas abiertas')
;
INSERT INTO disciplina (cod_disciplina, nombre) VALUES
    (9, 'Esgrima'),
    (10, 'Vela')
;

--5. TIPO_MEDALLA // SELECT * FROM tipo_medalla;
INSERT INTO tipo_medalla (cod_tipo, medalla) VALUES
    (1, 'Oro'),
    (2, 'Plata'),
    (3, 'Bronce'),
    (4, 'Platino')
;

--6. CATEGORIA // SELECT * FROM categoria;
INSERT INTO categoria (cod_categoria, categoria) VALUES
    (1, 'Clasificatorio'),
    (2, 'Eliminatorio'),
    (3, 'Final')
;

--7. TIPO_PARTICIPACION // SELECT * FROM tipo_participacion;
INSERT INTO tipo_participacion (cod_participacion, tipo_participacion) VALUES
    (1, 'Individual'),
    (2, 'Parejas'),
    (3, 'Equipos')
;

--8. MEDALLERO // SELECT * FROM medallero;
-- SELECT PAIS_cod_pais AS "Pais", TIPO_MEDALLA_cod_tipo AS "Tipo_medalla", cantidad_medallas AS "Cantidad_medallas" FROM medallero;
INSERT INTO medallero (PAIS_cod_pais, cantidad_medallas, TIPO_MEDALLA_cod_tipo) VALUES 
    (5, 3, 1),
    (2, 5, 1),
    (6, 4, 3),
    (4, 3, 4),
    (7, 10, 3),
    (3, 8, 2),
    (1, 2, 1),
    (1, 5, 4),
    (5, 7, 2)
;

--9.  SEDE // SELECT * FROM sede;
INSERT INTO sede (codigo, sede) VALUES 
    (1, 'Gimnasio Metropolitano de Tokio'),
    (2, 'Jardin del Palacio Imperial de Tokio'),
    (3, 'Gimnasio Nacional Yoyogi'),
    (4, 'Nippon Budokan'),
    (5, 'Estadio Olimpico')
;

--10. EVENTO // SELECT * FROM evento;
INSERT INTO evento (cod_evento, ubicacion, DISCIPLINA_cod_disciplina, TIPO_PARTICIPACION_cod_participacion, CATEGORIA_cod_categoria, fecha_hora) VALUES 
    (1, 3, 2, 2, 1, '24-07-2020 11:00:00'),
    (2, 1, 6, 1, 3, '26-07-2020 10:30:00'),
    (3, 5, 7, 1, 2, '30-07-2020 18:45:00'),
    (4, 2, 1, 1, 1, '1-08-2020 12:15:00'),
    (5, 4, 10, 3, 1,'8-08-2020 19:35:00')
;




/*
** 7. Después de que se implementó el script el cuál creó todas las tablas de las bases de datos, el Comité Olímpico Internacional tomó la decisión de eliminar la restricción “UNIQUE" de las siguientes tablas:
*/
--1. Pais - Nombre
ALTER TABLE pais DROP CONSTRAINT pais_nombre_key;

--2. Tipo_medalla - Medalla
ALTER TABLE tipo_medalla DROP CONSTRAINT tipo_medalla_medalla_key;

--3. Departamento - Nombre
ALTER TABLE departamento DROP CONSTRAINT departamento_nombre_key;




/*
** 8. Después de un análisis más profundo se decidió que los Atletas pueden participar en varias disciplinas y no sólo en una como está reflejado actualmente en las tablas, por lo que se pide que realice lo siguiente
*/
--a. Script que elimine la llave foránea de “cod_disciplina” que se encuentra en la tabla “Atleta”
ALTER TABLE atleta DROP CONSTRAINT atleta_disciplina_cod_disciplina_fkey;
--ALTER TABLE atleta DROP COLUMN DISCIPLINA_cod_disciplina;


--b. Script que cree una tabla con el nombre “Disciplina_Atleta” que contendrá los siguiente campos: cod_atleta (Llave foranea de atleta) y cod_disciplina (LLave foranea de discplina). Ambas seran llaves primarias.
CREATE TABLE disciplina_atleta (
    cod_atleta INTEGER NOT NULL,
    cod_disciplina INTEGER NOT NULL,

    PRIMARY KEY (cod_atleta, cod_disciplina),

    FOREIGN KEY (cod_atleta) REFERENCES atleta (cod_atleta) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cod_disciplina) REFERENCES disciplina (cod_disciplina) ON DELETE CASCADE ON UPDATE CASCADE
);




/*
** 9. En la tabla “Costo_Evento” se determinó que la columna “tarifa” no debe ser entero sino un decimal con 2 cifras de precisión
*/
ALTER TABLE costo_evento
    ALTER COLUMN tarifa TYPE FLOAT(2) USING tarifa::float
;




/*
** 10. Generar el Script que borre de la tabla “Tipo_Medalla”, el registro siguiente:
*/
DELETE FROM tipo_medalla 
    WHERE cod_tipo = 4
    AND medalla = 'Platino'
;




/*
** 11. La fecha de las olimpiadas está cerca y los preparativos siguen, pero de último momento se dieron problemas con las televisoras encargadas de transmitir los eventos, ya que no hay tiempo de solucionar los problemas que se dieron, se decidió no transmitir el evento a través de las televisoras por lo que el Comité Olímpico pide generar el script que elimine la tabla “TELEVISORAS” y “COSTO_EVENTO”
*/
--drop table if exists televisora CASCADE;
DROP TABLE costo_evento;
DROP TABLE televisora;




/*
** 12. El comité olímpico quiere replantear las disciplinas que van a llevarse a cabo, por lo cual pide generar el script que elimine todos los registros contenidos en la tabla “DISCIPLINA”
*/
DELETE FROM disciplina;




/*
** 13. Los miembros que no tenían registrado su número de teléfono en sus perfiles fueron notificados, por lo que se acercaron a las instalaciones de Comité para actualizar sus datos.
*/
--1. Laura Cunha Silva
UPDATE miembro SET telefono = 55464601
    WHERE nombre = 'Laura'
    AND apellido = 'Cunha Silva'
;

--2. Jeuel Villalpando
UPDATE miembro SET telefono = 55464601
    WHERE nombre = 'Jeuel'
    AND apellido = 'Villalpando'
;

--3. Scott Mitchell
UPDATE miembro SET telefono = 55464601
    WHERE nombre = 'Scott'
    AND apellido = 'Mitchell'
;




/*
** 14. El Comité decidió que necesita la fotografía en la información de los atletas para su perfil, por lo que se debe agregar la columna “Fotografía” a la tabla Atleta, debido a que es un cambio de última hora este campo deberá ser opcional
*/
--Se puede usar el BYTEA; o un OID (Object Identifier) en caso de usar un BLOB (binary large object) para procesar la imagen

--Elegi Bytea por que la imagenes no van a llegar a 1Gb que es donde este tipo empieza a tener inconvenientes 
--y por ende seria mas facil de manejar ya que es mas conocido el uso de arrays y ademas que los BLOB bajan el 
--rendimiento a la hora de eliminar registros agregandole que se necesita usar una API adicional para poder usarlos.
ALTER TABLE atleta ADD COLUMN fotografia BYTEA;




/*
** 15. Todos los atletas que se registren deben cumplir con ser menores a 25 años. De lo contrario no se debe poder registrar a un atleta en la base de datos.
*/
ALTER TABLE atleta ADD CONSTRAINT edad_check CHECK (
    edad < 25
);