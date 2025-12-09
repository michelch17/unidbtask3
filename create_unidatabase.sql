--
-- PostgreSQL database dump
--

\restrict bOcCLpzZJpTCVXw40fZXF9gMqjJuae3AJG12OvS4maY7bOquPUNrWXT2GY69s61

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: check_max_course_instances(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_max_course_instances() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    counter INT;
    max_instances INT;
    study_period_value VARCHAR(2);
    study_year_value INT;
BEGIN

    IF TG_OP = 'UPDATE'
    AND NEW.employee_id = OLD.employee_id
       AND NEW.course_instance_id = OLD.course_instance_id THEN
        RETURN NEW;
    END IF;

    SELECT study_period, study_year 
    INTO study_period_value, study_year_value
    FROM course_instance 
    WHERE course_instance_id = NEW.course_instance_id;

    SELECT rule_value INTO max_instances
    FROM teacher_rules 
    WHERE rule_name = 'max_instances_per_period';

    IF max_instances IS NULL THEN
        RAISE EXCEPTION 'Error: max_instances_per_period is not declared in teacher_rules';
    END IF;

    SELECT COUNT(DISTINCT ci.course_instance_id)
    INTO counter
    FROM allocation a
    JOIN course_instance ci ON a.course_instance_id = ci.course_instance_id
    WHERE a.employee_id = NEW.employee_id
      AND ci.study_period = study_period_value
      AND ci.study_year = study_year_value;

    IF counter >= max_instances THEN
        RAISE EXCEPTION
            'Teacher % cannot be allocated to more than % course instances in period % of year %. Currently assigned to: %',
            NEW.employee_id, max_instances, study_period_value, study_year_value, counter;
        END IF;

    RETURN NEW;
    END;

    $$;


ALTER FUNCTION public.check_max_course_instances() OWNER TO postgres;

--
-- Name: recalc_exam_admin_planned_hours(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recalc_exam_admin_planned_hours() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Recalculate Exam planned hours for this course instance
    WITH constants AS (
        SELECT
            MAX(CASE WHEN constant_name = 'exam_base_constant'   THEN constant_value END) AS exam_base,
            MAX(CASE WHEN constant_name = 'exam_student_factor'  THEN constant_value END) AS exam_student_factor
        FROM calculation_constants
    ),
    exam_activity AS (
        SELECT teaching_activity_id
        FROM teaching_activity
        WHERE teaching_activity_name = 'Exam'
    )
    INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours)
    SELECT
        ci.course_instance_id,
        exam_activity.teaching_activity_id,
        (constants.exam_base
         + constants.exam_student_factor * ci.num_students) AS planned_hours
    FROM course_instance ci
    CROSS JOIN constants
    CROSS JOIN exam_activity
    WHERE ci.course_instance_id = NEW.course_instance_id
    ON CONFLICT (course_instance_id, teaching_activity_id)
    DO UPDATE
    SET planned_hours = EXCLUDED.planned_hours;

    -- Recalculate Admin planned hours for this course instance
    WITH constants AS (
        SELECT
            MAX(CASE WHEN constant_name = 'admin_base_constant'    THEN constant_value END) AS admin_base,
            MAX(CASE WHEN constant_name = 'admin_hp_factor'        THEN constant_value END) AS admin_hp_factor,
            MAX(CASE WHEN constant_name = 'admin_student_factor'   THEN constant_value END) AS admin_student_factor
        FROM calculation_constants
    ),
    admin_activity AS (
        SELECT teaching_activity_id
        FROM teaching_activity
        WHERE teaching_activity_name = 'Admin'
    )
    INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours)
    SELECT
        ci.course_instance_id,
        admin_activity.teaching_activity_id,
        (
          constants.admin_hp_factor * cl.hp
          + constants.admin_base
          + constants.admin_student_factor * ci.num_students
        ) AS planned_hours
    FROM course_instance ci
    JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
    CROSS JOIN constants
    CROSS JOIN admin_activity
    WHERE ci.course_instance_id = NEW.course_instance_id
    ON CONFLICT (course_instance_id, teaching_activity_id)
    DO UPDATE
    SET planned_hours = EXCLUDED.planned_hours;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.recalc_exam_admin_planned_hours() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: allocation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.allocation (
    employee_id integer NOT NULL,
    course_instance_id integer NOT NULL,
    teaching_activity_id integer NOT NULL,
    allocated_hours numeric(6,2) NOT NULL
);


ALTER TABLE public.allocation OWNER TO postgres;

--
-- Name: calculation_constants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calculation_constants (
    constant_name character varying(50) NOT NULL,
    constant_value numeric(10,4)
);


ALTER TABLE public.calculation_constants OWNER TO postgres;

--
-- Name: course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course (
    course_id integer NOT NULL,
    course_code character varying(6) NOT NULL,
    course_name character varying(50) NOT NULL
);


ALTER TABLE public.course OWNER TO postgres;

--
-- Name: course_course_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.course ALTER COLUMN course_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: course_instance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_instance (
    course_instance_id integer NOT NULL,
    course_layout_id integer NOT NULL,
    num_students integer NOT NULL,
    study_period character varying(2) NOT NULL,
    study_year integer NOT NULL,
    CONSTRAINT course_instance_study_period_check CHECK (((study_period)::text = ANY (ARRAY[('P1'::character varying)::text, ('P2'::character varying)::text, ('P3'::character varying)::text, ('P4'::character varying)::text])))
);


ALTER TABLE public.course_instance OWNER TO postgres;

--
-- Name: course_instance_course_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.course_instance ALTER COLUMN course_instance_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_instance_course_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: course_layout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_layout (
    course_layout_id integer CONSTRAINT course_layout_layout_id_not_null NOT NULL,
    course_id integer NOT NULL,
    version_no integer NOT NULL,
    hp numeric(4,2) NOT NULL,
    min_students integer NOT NULL,
    max_students integer NOT NULL
);


ALTER TABLE public.course_layout OWNER TO postgres;

--
-- Name: course_layout_layout_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.course_layout ALTER COLUMN course_layout_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.course_layout_layout_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department (
    department_id integer CONSTRAINT deparment_department_id_not_null NOT NULL,
    department_name character varying(50) CONSTRAINT deparment_department_name_not_null NOT NULL,
    manager_employee_id integer
);


ALTER TABLE public.department OWNER TO postgres;

--
-- Name: deparment_department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.department ALTER COLUMN department_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.deparment_department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    employee_id integer NOT NULL,
    person_id integer NOT NULL,
    department_id integer NOT NULL,
    job_title_id integer NOT NULL,
    manager_id integer
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- Name: employee_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.employee ALTER COLUMN employee_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.employee_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: job_title; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_title (
    job_title_id integer NOT NULL,
    job_title_name character varying(50) NOT NULL
);


ALTER TABLE public.job_title OWNER TO postgres;

--
-- Name: job_title_job_title_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.job_title ALTER COLUMN job_title_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.job_title_job_title_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: planned_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.planned_activity (
    course_instance_id integer NOT NULL,
    teaching_activity_id integer NOT NULL,
    planned_hours numeric(6,2) NOT NULL
);


ALTER TABLE public.planned_activity OWNER TO postgres;

--
-- Name: teaching_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teaching_activity (
    teaching_activity_id integer NOT NULL,
    teaching_activity_name character varying(50) NOT NULL,
    factor numeric(3,2) NOT NULL
);


ALTER TABLE public.teaching_activity OWNER TO postgres;

--
-- Name: mv_planned_allocated_variance; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_planned_allocated_variance AS
 WITH planned AS (
         SELECT course.course_code,
            course_instance.course_instance_id,
            sum((planned_activity.planned_hours * teaching_activity.factor)) AS planned_teaching_hours,
            (( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'exam_base_constant'::text)) + (( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'exam_student_factor'::text)) * (course_instance.num_students)::numeric)) AS exam_hours,
            (((( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'admin_hp_factor'::text)) * course_layout.hp) + ( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'admin_base_constant'::text))) + (( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'admin_student_factor'::text)) * (course_instance.num_students)::numeric)) AS admin_hours,
            ((sum((planned_activity.planned_hours * teaching_activity.factor)) + (( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'exam_base_constant'::text)) + (( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'exam_student_factor'::text)) * (course_instance.num_students)::numeric))) + (((( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'admin_hp_factor'::text)) * course_layout.hp) + ( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'admin_base_constant'::text))) + (( SELECT calculation_constants.constant_value
                   FROM public.calculation_constants
                  WHERE ((calculation_constants.constant_name)::text = 'admin_student_factor'::text)) * (course_instance.num_students)::numeric))) AS total_planned_hours
           FROM ((((public.course_instance
             JOIN public.course_layout ON ((course_instance.course_layout_id = course_layout.course_layout_id)))
             JOIN public.course ON ((course_layout.course_id = course.course_id)))
             JOIN public.planned_activity ON ((course_instance.course_instance_id = planned_activity.course_instance_id)))
             JOIN public.teaching_activity ON ((planned_activity.teaching_activity_id = teaching_activity.teaching_activity_id)))
          WHERE (course_instance.study_year = 2025)
          GROUP BY course.course_code, course_instance.course_instance_id, course_layout.hp, course_instance.num_students
        ), allocated AS (
         SELECT course_instance.course_instance_id,
            sum((allocation.allocated_hours * teaching_activity.factor)) AS total_allocated_hours
           FROM ((public.allocation
             JOIN public.course_instance ON ((allocation.course_instance_id = course_instance.course_instance_id)))
             JOIN public.teaching_activity ON ((allocation.teaching_activity_id = teaching_activity.teaching_activity_id)))
          WHERE (course_instance.study_year = 2025)
          GROUP BY course_instance.course_instance_id
        )
 SELECT planned.course_code,
    planned.course_instance_id,
    planned.total_planned_hours,
    allocated.total_allocated_hours,
    (((allocated.total_allocated_hours - planned.total_planned_hours) / planned.total_planned_hours) * (100)::numeric) AS variance_percent
   FROM (planned
     JOIN allocated ON ((planned.course_instance_id = allocated.course_instance_id)))
  WHERE ((planned.total_planned_hours > (0)::numeric) AND (abs(((allocated.total_allocated_hours - planned.total_planned_hours) / planned.total_planned_hours)) > 0.15))
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_planned_allocated_variance OWNER TO postgres;

--
-- Name: mv_planned_hours; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_planned_hours AS
 SELECT course.course_code,
    course_instance.course_instance_id,
    course_layout.hp,
    course_instance.study_period AS period,
    course_instance.num_students,
    sum((planned_activity.planned_hours * teaching_activity.factor)) FILTER (WHERE ((teaching_activity.teaching_activity_name)::text = 'Lecture'::text)) AS lecture_hours,
    sum((planned_activity.planned_hours * teaching_activity.factor)) FILTER (WHERE ((teaching_activity.teaching_activity_name)::text = 'Tutorial'::text)) AS tutorial_hours,
    sum((planned_activity.planned_hours * teaching_activity.factor)) FILTER (WHERE ((teaching_activity.teaching_activity_name)::text = 'Lab'::text)) AS lab_hours,
    sum((planned_activity.planned_hours * teaching_activity.factor)) FILTER (WHERE ((teaching_activity.teaching_activity_name)::text = 'Seminar'::text)) AS seminar_hours,
    sum((planned_activity.planned_hours * teaching_activity.factor)) FILTER (WHERE ((teaching_activity.teaching_activity_name)::text = 'Other'::text)) AS other_hours,
    (( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'exam_base_constant'::text)) + (( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'exam_student_factor'::text)) * (course_instance.num_students)::numeric)) AS exam_hours,
    (((( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'admin_hp_factor'::text)) * course_layout.hp) + ( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'admin_base_constant'::text))) + (( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'admin_student_factor'::text)) * (course_instance.num_students)::numeric)) AS admin_hours,
    ((sum((planned_activity.planned_hours * teaching_activity.factor)) + (( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'exam_base_constant'::text)) + (( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'exam_student_factor'::text)) * (course_instance.num_students)::numeric))) + (((( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'admin_hp_factor'::text)) * course_layout.hp) + ( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'admin_base_constant'::text))) + (( SELECT calculation_constants.constant_value
           FROM public.calculation_constants
          WHERE ((calculation_constants.constant_name)::text = 'admin_student_factor'::text)) * (course_instance.num_students)::numeric))) AS total_hours
   FROM ((((public.course_instance
     JOIN public.course_layout ON ((course_instance.course_layout_id = course_layout.course_layout_id)))
     JOIN public.course ON ((course_layout.course_id = course.course_id)))
     JOIN public.planned_activity ON ((course_instance.course_instance_id = planned_activity.course_instance_id)))
     JOIN public.teaching_activity ON ((planned_activity.teaching_activity_id = teaching_activity.teaching_activity_id)))
  WHERE (course_instance.study_year = 2025)
  GROUP BY course.course_code, course_instance.course_instance_id, course_layout.hp, course_instance.study_period, course_instance.num_students
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_planned_hours OWNER TO postgres;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    person_id integer NOT NULL,
    personal_number character varying(12) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    phone_number character varying(20),
    address character varying(50)
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: person_person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.person ALTER COLUMN person_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.person_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: salary_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salary_history (
    employee_id integer NOT NULL,
    valid_from date NOT NULL,
    valid_to date,
    salary_amount numeric(10,2) NOT NULL
);


ALTER TABLE public.salary_history OWNER TO postgres;

--
-- Name: skill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skill (
    skill_id integer NOT NULL,
    skill_name character varying(50) NOT NULL
);


ALTER TABLE public.skill OWNER TO postgres;

--
-- Name: skill_skill_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.skill ALTER COLUMN skill_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.skill_skill_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: teacher_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_rules (
    rule_name character varying(50) NOT NULL,
    rule_value integer NOT NULL
);


ALTER TABLE public.teacher_rules OWNER TO postgres;

--
-- Name: teacher_skill; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_skill (
    employee_id integer NOT NULL,
    skill_id integer NOT NULL
);


ALTER TABLE public.teacher_skill OWNER TO postgres;

--
-- Name: teaching_activity_teaching_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.teaching_activity ALTER COLUMN teaching_activity_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.teaching_activity_teaching_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: allocation allocation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT allocation_pkey PRIMARY KEY (employee_id, course_instance_id, teaching_activity_id);


--
-- Name: calculation_constants calculation_constants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calculation_constants
    ADD CONSTRAINT calculation_constants_pkey PRIMARY KEY (constant_name);


--
-- Name: course course_course_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_course_code_key UNIQUE (course_code);


--
-- Name: course_instance course_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT course_instance_pkey PRIMARY KEY (course_instance_id);


--
-- Name: course_layout course_layout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_layout
    ADD CONSTRAINT course_layout_pkey PRIMARY KEY (course_layout_id);


--
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (course_id);


--
-- Name: department deparment_department_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT deparment_department_name_key UNIQUE (department_name);


--
-- Name: department deparment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT deparment_pkey PRIMARY KEY (department_id);


--
-- Name: department department_manager_employee_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_manager_employee_id_key UNIQUE (manager_employee_id);


--
-- Name: employee employee_person_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_person_id_key UNIQUE (person_id);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- Name: job_title job_title_job_title_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_title
    ADD CONSTRAINT job_title_job_title_name_key UNIQUE (job_title_name);


--
-- Name: job_title job_title_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_title
    ADD CONSTRAINT job_title_pkey PRIMARY KEY (job_title_id);


--
-- Name: person person_personal_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_personal_number_key UNIQUE (personal_number);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);


--
-- Name: planned_activity planned_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planned_activity
    ADD CONSTRAINT planned_activity_pkey PRIMARY KEY (course_instance_id, teaching_activity_id);


--
-- Name: salary_history salary_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_history
    ADD CONSTRAINT salary_history_pkey PRIMARY KEY (employee_id, valid_from);


--
-- Name: skill skill_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skill
    ADD CONSTRAINT skill_pkey PRIMARY KEY (skill_id);


--
-- Name: skill skill_skill_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skill
    ADD CONSTRAINT skill_skill_name_key UNIQUE (skill_name);


--
-- Name: teacher_rules teacher_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_rules
    ADD CONSTRAINT teacher_rules_pkey PRIMARY KEY (rule_name);


--
-- Name: teacher_skill teacher_skill_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_skill
    ADD CONSTRAINT teacher_skill_pkey PRIMARY KEY (employee_id, skill_id);


--
-- Name: teaching_activity teaching_activity_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_activity
    ADD CONSTRAINT teaching_activity_name_unique UNIQUE (teaching_activity_name);


--
-- Name: teaching_activity teaching_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teaching_activity
    ADD CONSTRAINT teaching_activity_pkey PRIMARY KEY (teaching_activity_id);


--
-- Name: index_allocation_course_employee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_allocation_course_employee ON public.allocation USING btree (course_instance_id, employee_id, teaching_activity_id);


--
-- Name: index_allocation_employee_course; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_allocation_employee_course ON public.allocation USING btree (employee_id, course_instance_id, teaching_activity_id);


--
-- Name: index_course_instance_year_period; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_course_instance_year_period ON public.course_instance USING btree (study_year, study_period, course_instance_id);


--
-- Name: allocation teacher_course_allo_max; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER teacher_course_allo_max BEFORE INSERT OR UPDATE OF employee_id, course_instance_id ON public.allocation FOR EACH ROW EXECUTE FUNCTION public.check_max_course_instances();


--
-- Name: course_instance trg_recalc_exam_admin_planned_hours; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_recalc_exam_admin_planned_hours AFTER UPDATE OF num_students ON public.course_instance FOR EACH ROW WHEN ((old.num_students IS DISTINCT FROM new.num_students)) EXECUTE FUNCTION public.recalc_exam_admin_planned_hours();


--
-- Name: allocation allocation_course_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT allocation_course_instance_id_fkey FOREIGN KEY (course_instance_id) REFERENCES public.course_instance(course_instance_id) ON DELETE CASCADE;


--
-- Name: allocation allocation_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT allocation_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON DELETE CASCADE;


--
-- Name: allocation allocation_teaching_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.allocation
    ADD CONSTRAINT allocation_teaching_activity_id_fkey FOREIGN KEY (teaching_activity_id) REFERENCES public.teaching_activity(teaching_activity_id) ON DELETE CASCADE;


--
-- Name: course_instance course_instance_course_layout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT course_instance_course_layout_id_fkey FOREIGN KEY (course_layout_id) REFERENCES public.course_layout(course_layout_id);


--
-- Name: course_layout course_layout_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_layout
    ADD CONSTRAINT course_layout_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.course(course_id) ON DELETE CASCADE;


--
-- Name: employee employee_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department(department_id) ON DELETE SET NULL;


--
-- Name: employee employee_job_title_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_job_title_id_fkey FOREIGN KEY (job_title_id) REFERENCES public.job_title(job_title_id) ON DELETE SET NULL;


--
-- Name: employee employee_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.employee(employee_id) ON DELETE SET NULL;


--
-- Name: employee employee_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE CASCADE;


--
-- Name: department fk_department_manager; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT fk_department_manager FOREIGN KEY (manager_employee_id) REFERENCES public.employee(employee_id) ON DELETE SET NULL;


--
-- Name: planned_activity planned_activity_course_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planned_activity
    ADD CONSTRAINT planned_activity_course_instance_id_fkey FOREIGN KEY (course_instance_id) REFERENCES public.course_instance(course_instance_id) ON DELETE CASCADE;


--
-- Name: planned_activity planned_activity_teaching_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.planned_activity
    ADD CONSTRAINT planned_activity_teaching_activity_id_fkey FOREIGN KEY (teaching_activity_id) REFERENCES public.teaching_activity(teaching_activity_id) ON DELETE CASCADE;


--
-- Name: salary_history salary_history_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_history
    ADD CONSTRAINT salary_history_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON DELETE CASCADE;


--
-- Name: teacher_skill teacher_skill_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_skill
    ADD CONSTRAINT teacher_skill_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON DELETE CASCADE;


--
-- Name: teacher_skill teacher_skill_skill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_skill
    ADD CONSTRAINT teacher_skill_skill_id_fkey FOREIGN KEY (skill_id) REFERENCES public.skill(skill_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict bOcCLpzZJpTCVXw40fZXF9gMqjJuae3AJG12OvS4maY7bOquPUNrWXT2GY69s61

