--2.6.1 Procedimento Armazenado 

CREATE PROCEDURE inc_semestre(IN target_semestre INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE aluno
    SET semestre = semestre + 1
    WHERE semestre = target_semestre;
    RAISE NOTICE 'Semestre incrementado para alunos do semestre %', target_semestre;
END;
$$;

--2.7.1 Triggers
CREATE FUNCTION verificar_capacidade_turma()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    
    IF (
        SELECT COUNT(*)
        FROM aluno_turma
        WHERE turma_id = NEW.turma_id
    ) >= (
        SELECT turma.capacidade_maxima
        FROM turma
        WHERE id = NEW.turma_id
    ) THEN
        
        RAISE EXCEPTION 'A turma % já atingiu a capacidade máxima.', NEW.turma_id;
    END IF;

    
    RETURN NEW;
END;
$$;

CREATE TRIGGER verificar_capacidade_antes_inserir
BEFORE INSERT ON aluno_turma
FOR EACH ROW
EXECUTE FUNCTION verificar_capacidade_turma();


--2.7.2 Triggers

CREATE FUNCTION verificar_maximo_disciplina()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

	IF (
		SELECT COUNT(*)
		FROM aluno_turma 
		WHERE aluno_id = NEW.aluno_id 		
	) >=4 THEN 
		RAISE EXCEPTION 'O aluno % já está matriculado em 4 disciplinas nesse semestre.', NEW.aluno_id;
	END IF;


	RETURN NEW;
END;
$$;

CREATE TRIGGER trig_verificar_maximo_disciplina 
BEFORE INSERT ON aluno_turma 
FOR EACH ROW 
EXECUTE FUNCTION verificar_maximo_disciplina();
