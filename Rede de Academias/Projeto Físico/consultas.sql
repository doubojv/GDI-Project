 /*
 Seu projeto deve ter todos os tipos de consultas abaixo
-Group by/Having CHECK
-Junção interna CHECK
-Junção externa CHECK
-Semi junção CHECK
-Anti-junção CHECK
-Subconsulta do tipo escalar CHECK
-Subconsulta do tipo linha CHECK
-Subconsulta do tipo tabela CHECK
-Operação de conjunto CHECK
*/


-- Usando Group By/Having --

--Quais academias tem mais de 1 extensora?--
SELECT ID_ACAD, COUNT(*)
FROM MAQUINAS
WHERE NOME = 'Extensora'
GROUP BY ID_ACAD
HAVING COUNT(*) > 1;

-- Usando Junção interna --

--Alunos e suas respectivas academias--
SELECT DISTINCT A.NOME, F.ID_ACAD
FROM ALUNO A INNER JOIN TREINO T ON A.CPF = T.CPF_ALUNO INNER JOIN FUNCIONARIOS F ON F.CPF = T.CPF_PROF;

--Academia que os alunos sem promoção frequentam--
SELECT DISTINCT A.NOME, F.ID_ACAD
FROM ALUNO A 
INNER JOIN CADASTRO C ON A.CPF = C.CPF 
INNER JOIN TREINO T ON T.CPF_ALUNO = A.CPF
INNER JOIN FUNCIONARIOS F ON F.CPF = T.CPF_PROF
WHERE C.ID_PROMO IS NULL ;


-- Usando Junção externa --

--Alunos que nunca pegaram plano premium--
SELECT DISTINCT A.NOME
FROM ALUNO A LEFT OUTER JOIN CADASTRO C ON C.CPF = A.CPF
WHERE C.COD = 'PLS';


-- Usando Semi join --

--Quais alunos treinam perna--
SELECT A.NOME
FROM ALUNO A 
WHERE EXISTS (SELECT T.COD FROM TREINO T WHERE (T.CPF_ALUNO = A.CPF) AND (T.COD = 'C')) ;


-- Usando anti join --

--Quais alunos NÃO treinam perna--
SELECT A.NOME
FROM ALUNO A 
WHERE NOT EXISTS (SELECT T.COD FROM TREINO T WHERE (T.CPF_ALUNO = A.CPF) AND (T.COD = 'C'));


-- Usando subselect tipo escalar --

--Quais academias tem mais máquinas que a media EMBARCANDO NA VIAAAGEM--
SELECT ID_ACAD, COUNT(*)
FROM MAQUINAS
GROUP BY ID_ACAD
HAVING COUNT(*) > (SELECT AVG(QTD) FROM (SELECT COUNT(*) AS QTD, ID_ACAD FROM MAQUINAS GROUP BY ID_ACAD));


-- Usando subselect tipo linha --

--ID da academia com mais máquinas--
SELECT ID_ACAD
FROM (SELECT ID_ACAD, COUNT(*) FROM MAQUINAS GROUP BY ID_ACAD HAVING COUNT(*) = (SELECT MAX(QTD) FROM (SELECT COUNT(*) AS QTD, ID_ACAD FROM MAQUINAS GROUP BY ID_ACAD)));
  

-- Usando subselect tipo tabela --

-- Quais alunos treinam com mais de 1 professor--
SELECT A.NOME , COUNT(*) AS QTD_PROF
FROM (SELECT DISTINCT CPF_ALUNO, CPF_PROF FROM TREINO) INNER JOIN ALUNO A ON CPF_ALUNO = A.CPF
GROUP BY A.NOME
HAVING COUNT(*) > 1;


-- Usando operação de conjunto -- 

-- Alunos e suas respectivas academias--
SELECT DISTINCT A.NOME, F.ID_ACAD
FROM ALUNO A, TREINO T, FUNCIONARIOS F
WHERE A.CPF = T.CPF_ALUNO AND T.CPF_PROF = F.CPF;



------PROCEDURES E FUNCTIONS--------------------

----Procedure01 -> Exibe a quantidade de maquinas por acad

-- EXIBIR A QTD DE MAQUINA POR ACAD

CREATE OR REPLACE PROCEDURE EXIBIR_QTD(ID VARCHAR) IS
	QTD NUMBER;
BEGIN
	SELECT COUNT(*) INTO QTD FROM MAQUINAS WHERE ID_ACAD = ID;
	dbms_output.put_line('A quantidade de maquinas na Academia'||ID|| ' Ã© : ' ||QTD);
END;

----Procedure02 -> Insere promocao 


CREATE OR REPLACE PROCEDURE INSERT_PROMO(ID VARCHAR, DESCONTO NUMBER) IS
BEGIN
	INSERT INTO PROMOCAO VALUES(ID,DESCONTO);
END;
 
EXEC INSERT_PROMO('PROMO006', 50.3)


----Procedure03 -> Alunos por treino


CREATE OR REPLACE PROCEDURE PRINTA_ALUNOS(CODE VARCHAR) IS
    NOME VARCHAR(15);
CURSOR CUR IS
    (SELECT A.NOME
	FROM ALUNO A 
	WHERE EXISTS (SELECT T.COD FROM TREINO T WHERE (T.CPF_ALUNO = A.CPF) AND (T.COD = CODE)));
BEGIN 
	OPEN CUR;
	FETCH CUR INTO NOME;
	dbms_output.put_line('Alunos que fazem '||CODE);
	WHILE CUR%found LOOP
        dbms_output.put_line(NOME);
	FETCH CUR INTO NOME;
	END LOOP;
END;

EXEC PRINTA_ALUNOS('A');



----Procedure04 -> Alunos por academia


CREATE OR REPLACE PROCEDURE PRINTA_ALUNOS_ACAD(ID VARCHAR) IS
    NOME VARCHAR(15);
CURSOR CUR IS
    (SELECT DISTINCT A.NOME
	FROM ALUNO A, TREINO T, FUNCIONARIOS F
	WHERE A.CPF = T.CPF_ALUNO AND T.CPF_PROF = F.CPF AND F.ID_ACAD = ID);
BEGIN 
	OPEN CUR;
	FETCH CUR INTO NOME;
	dbms_output.put_line('Alunos que sÃ£o da academia  '||ID);
	WHILE CUR%found LOOP
        dbms_output.put_line(NOME);
		FETCH CUR INTO NOME;
	END LOOP;
END; 


EXEC PRINTA_ALUNOS_ACAD('ACAD001');



------Procedure05 -> Trata do caso N-N total-parcial

CREATE OR REPLACE PROCEDURE INSERE_ALUNO(CPF VARCHAR ,Nome VARCHAR ,Sexo CHAR ,Nasc DATE ,End_CEP VARCHAR ,End_Comp VARCHAR ,End_NÂº VARCHAR, COD VARCHAR, ID_PROMO VARCHAR) IS
DT DATE;    
BEGIN
    SELECT CURRENT_DATE INTO DT FROM DUAL;
	IF COD IS NOT NULL THEN 
    	INSERT INTO ALUNO VALUES (CPF,Nome,Sexo ,Nasc,End_CEP,End_Comp,End_NÂº);
		INSERT INTO CADASTRO VALUES(CPF, COD, DT, ID_PROMO);
    END IF;
END; 

EXEC INSERE_ALUNO('000.516.311-23', 'LARRY', 'M', TO_DATE('23/06/1982','DD/MM/YYYY'), '52000004', 'apt 403', '700', NULL, 'PROMO002');


-----Function01 -> Exibe a quantidade de maquinas por acad

CREATE OR REPLACE FUNCTION GET_QTD_MACHINES(ID VARCHAR) RETURN NUMBER IS
QTD NUMBER;
BEGIN 
	SELECT COUNT(*) INTO QTD FROM MAQUINAS WHERE ID_ACAD = ID;
	RETURN QTD;
END;


SELECT DISTINCT ID_ACAD, GET_QTD_MACHINES(ID_ACAD) AS QTD_MAQUINAS
FROM MAQUINAS
