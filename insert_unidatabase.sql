--
-- PostgreSQL database dump
--

\restrict wbrgxxcWTcRRLre157do93hzs4OZFhYooVGBTGgs4JxWP08JA75a6x36VektGKn

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', 'public', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: course; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course (course_id, course_code, course_name) FROM stdin;
1	CS101	Introduction to Computer Science
2	MATH01	Calculus I
3	ECON02	Principles of Economics
\.


--
-- Data for Name: course_layout; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course_layout (course_layout_id, course_id, version_no, hp, min_students, max_students) FROM stdin;
1	1	1	7.50	5	30
2	2	1	7.50	5	30
3	3	1	7.50	5	30
\.


--
-- Data for Name: course_instance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course_instance (course_instance_id, course_layout_id, num_students, study_period, study_year) FROM stdin;
1	1	20	P1	2025
2	2	18	P2	2025
3	3	15	P1	2025
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: postgres
--

-- Departments (managers will be set later)
COPY public.department (department_id, department_name, manager_employee_id) FROM stdin;
1	Computer Science	\N
2	Mathematics	\N
3	Economics	\N
\.



--
-- Data for Name: job_title; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_title (job_title_id, job_title_name) FROM stdin;
1	Manager
2	Staff
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.person (person_id, personal_number, first_name, last_name, phone_number, address) FROM stdin;
1	707-40-9857	Jena	Kittow	589-942-1641	14 Mariners Cove Street
2	498-84-1901	Barny	Laws	631-301-5190	57 Elka Court
3	502-90-1113	Ferdinande	Pesterfield	581-256-0060	9 Service Street
4	472-81-5316	Marilyn	Screeton	322-141-7718	8 Cascade Lane
5	278-02-1046	Matthus	De Bruijn	118-299-1231	238 Independence Pass
6	328-42-1927	Alysa	Frostdicke	818-186-6901	5797 Bonner Court
7	557-08-2997	Witty	Boyland	363-379-2594	82241 Merchant Court
8	601-40-5073	Minor	Darrel	318-611-7671	9855 Macpherson Road
9	661-35-7247	Virginie	Laurentino	659-529-2793	9 Chive Road
10	659-06-3943	Ninnetta	Tremonte	192-591-6989	56847 Onsgard Lane
11	217-58-3490	Leisha	Crannis	735-789-6423	35 Declaration Court
12	319-90-1293	Sherlocke	Brotherhead	128-172-8485	99005 Surrey Crossing
\.


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (employee_id, person_id, department_id, job_title_id, manager_id) FROM stdin;
1	1	1	1	\N
2	2	2	1	\N
3	3	3	1	\N
4	4	1	2	1
5	5	1	2	1
6	6	1	2	1
7	7	2	2	2
8	8	2	2	2
9	9	2	2	2
10	10	3	2	3
11	11	3	2	3
12	12	3	2	3
\.

UPDATE public.department SET manager_employee_id = 1 WHERE department_id = 1;
UPDATE public.department SET manager_employee_id = 2 WHERE department_id = 2;
UPDATE public.department SET manager_employee_id = 3 WHERE department_id = 3;


--
-- Data for Name: teaching_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teaching_activity (teaching_activity_id, teaching_activity_name, factor) FROM stdin;
1	Lecture	3.60
2	Lab	2.40
3	Tutorial	2.40
4	Seminar	1.80
5	Other	2.00
6	Exam	1.00
7	Admin	1.00
\.



-- Data for Name: teacher_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher_rules (rule_name, rule_value) FROM stdin;
max_instances_per_period	4
\.

--
-- Data for Name: allocation; Type: TABLE DATA; Schema: public; Owner: postgres
--


COPY public.allocation (employee_id, course_instance_id, teaching_activity_id, allocated_hours) FROM stdin;
4	1	1	20.00
4	1	2	10.00
4	1	3	8.00
4	1	4	5.00
5	1	1	20.00
5	1	2	10.00
5	1	3	8.00
5	1	4	5.00
6	1	1	20.00
6	1	2	10.00
6	1	3	8.00
6	1	4	5.00
7	2	1	20.00
7	2	2	10.00
7	2	3	8.00
7	2	4	5.00
8	2	1	20.00
8	2	2	10.00
8	2	3	8.00
8	2	4	5.00
9	2	1	20.00
9	2	2	10.00
9	2	3	8.00
9	2	4	5.00
10	3	1	20.00
10	3	2	10.00
10	3	3	8.00
10	3	4	5.00
11	3	1	20.00
11	3	2	10.00
11	3	3	8.00
11	3	4	5.00
12	3	1	20.00
12	3	2	10.00
12	3	3	8.00
12	3	4	5.00
10	1	1	8.00
\.



--
-- Data for Name: calculation_constants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calculation_constants (constant_name, constant_value) FROM stdin;
exam_base_constant	32.0000
exam_student_factor	0.7250
admin_base_constant	28.0000
admin_hp_factor	2.0000
admin_student_factor	0.2000
\.


--
-- Data for Name: planned_activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.planned_activity (course_instance_id, teaching_activity_id, planned_hours) FROM stdin;
1	1	20.00
1	2	10.00
1	3	5.00
1	4	5.00
1	5	0.00
2	1	25.00
2	2	12.00
2	3	6.00
2	4	4.00
2	5	0.00
3	1	18.00
3	2	8.00
3	3	6.00
3	4	3.00
3	5	0.00
\.

--
-- Data for Name: salary_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.salary_history (employee_id, valid_from, valid_to, salary_amount) FROM stdin;
1	2020-01-01	\N	120000.00
2	2020-01-01	\N	115000.00
3	2020-01-01	\N	110000.00
4	2021-06-10	\N	70000.00
5	2023-01-05	\N	68000.00
6	2024-08-12	\N	72000.00
7	2024-07-09	\N	70000.00
8	2023-07-15	\N	68000.00
9	2022-03-20	\N	72000.00
10	2021-05-10	\N	65000.00
11	2024-09-23	\N	64000.00
12	2022-02-04	\N	66000.00
\.


--
-- Data for Name: skill; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skill (skill_id, skill_name) FROM stdin;
1	Programming
2	Algorithms
3	Calculus
4	Microeconomics
5	Teaching
\.

--
-- Data for Name: teacher_skill; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher_skill (employee_id, skill_id) FROM stdin;
1	1
1	2
1	5
2	3
2	5
3	4
3	5
4	1
4	2
4	5
5	1
5	2
5	5
6	1
6	2
6	5
7	3
7	5
8	3
8	5
9	3
9	5
10	4
10	5
11	4
11	5
12	4
12	5
\.


--
-- Name: course_course_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_course_id_seq', 3, true);


--
-- Name: course_instance_course_instance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_instance_course_instance_id_seq', 3, true);


--
-- Name: course_layout_layout_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.course_layout_layout_id_seq', 3, true);


--
-- Name: deparment_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.deparment_department_id_seq', 3, true);


--
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_employee_id_seq', 12, true);


--
-- Name: job_title_job_title_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_title_job_title_id_seq', 2, true);


--
-- Name: person_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.person_person_id_seq', 12, true);


--
-- Name: skill_skill_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.skill_skill_id_seq', 5, true);


--
-- Name: teaching_activity_teaching_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teaching_activity_teaching_activity_id_seq', 4, true);

SELECT setval(
    'teaching_activity_teaching_activity_id_seq',
    (SELECT MAX(teaching_activity_id) FROM teaching_activity)
);

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
ON CONFLICT (course_instance_id, teaching_activity_id)
DO UPDATE
SET planned_hours = EXCLUDED.planned_hours;

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
ON CONFLICT (course_instance_id, teaching_activity_id)
DO UPDATE
SET planned_hours = EXCLUDED.planned_hours;

INSERT INTO course_instance (course_layout_id, num_students, study_period, study_year)
VALUES
    (1, 25, 'P1', 2025),
    (1, 30, 'P1', 2025),
    (1, 20, 'P1', 2025);

INSERT INTO allocation (employee_id, course_instance_id, teaching_activity_id, allocated_hours)
VALUES (10, 4, 1, 5.00);
INSERT INTO allocation (employee_id, course_instance_id, teaching_activity_id, allocated_hours)
VALUES (10, 5, 1, 5.00);
--
-- PostgreSQL database dump complete
--

\unrestrict wbrgxxcWTcRRLre157do93hzs4OZFhYooVGBTGgs4JxWP08JA75a6x36VektGKn

