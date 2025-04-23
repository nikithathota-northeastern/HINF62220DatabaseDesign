-- List of Students who are enrolled for more than allowed credits in a semester . This is useful to flag students when they are taking more courses than permitted in a semester at the university.
-- List of courses which a student can enroll based on prerequisites and the program of the study. This is useful for the student to understand the courses they can register for in the semester.
-- List of students who have met the program requirements and are eligible for graduation. This can be useful to flag students that they are taking extra credits that go beyond the program requirements.
-- List of students who are enrolled in multiple courses that are happening at the same time. This is useful to help the students resolve scheduling conflicts.
-- List of Instructors that are taking more than ‘x’ classes to ensure the workload is evenly distributed.
-- List of courses that have least student registrations. It is important to ensure for the institutions that a minimum ‘x’ number of students are enrolled in every course they are offering.
-- List of courses with a full waitlist of student registrations. This is useful to either increase the student count for a class or provide alternate options to students to help them decide.
-- List of courses that share overlapping time and are assigned to the same room. This helps institutions to schedule classes without such overlaps.
-- List of average number of courses taken per student per semester. This helps institutions in academic planning by providing insights into student course load trends.

USE nthota;

-- Q1
SELECT SCR.StudentFK, COUNT(CoursesKey) as Num_Courses_Reigstered FROM StudentCourseRegistration as SCR
	JOIN Courses as C
    ON C.CoursesKey = SCR.CourseFK
WHERE
EndDate > current_date()
AND RegistrationStatus = 'Registered'
AND Year = 2025 AND Semester = 'Spring'
GROUP BY 1
HAVING COUNT(CoursesKey) > 5;

-- Q2
SELECT DISTINCT(StudentFK) FROM studentcourses WHERE CoursesFK = 'MSAI106'
AND StudentFK in (
	SELECT StudentFK FROM studentcourseregistration as SCR
    WHERE  RegistrationStatus = 'Finished' AND
    CourseFK IN (SELECT PreReqCourse FROM courseprereqs WHERE CourseKey = 'MSAI106')
);

-- Q3
SELECT
IF(SUM(Credits)>=P.ProgramCredits, "Graduated", "Not Graduated"), SUM(Credits), StudentFK, ProgramFK FROM Courses AS C
JOIN StudentCourseRegistration AS SCR ON C.CoursesKey = SCR.CourseFK
JOIN program as P ON C.ProgramFK = P.ProgramKey
WHERE RegistrationStatus = 'Finished'
AND P.ProgramKey = 3
GROUP BY StudentFK, ProgramFK
ORDER BY 1;

-- Q4
SELECT CS.CoursesFK, StudentFK, Day, StartTime, EndTime FROM StudentCourseRegistration AS SCR
JOIN Courseschedule as CS ON SCR.CourseFK = CS.CoursesFK
WHERE RegistrationStatus = 'Registered';

-- Q5
SELECT COUNT(*), InstructorFK, Semester, Year as num_courses
FROM Courses
WHERE Year = 2025 AND Semester = 'Spring'
GROUP BY 2, 3, 4
HAVING COUNT(*) > 2
ORDER BY 1 DESC;

-- Q6
SELECT COUNT(SCR.StudentFK), SCR.CourseFK FROM StudentCourseRegistration AS SCR
JOIN Courses AS C ON C.CoursesKey = SCR.CourseFK
WHERE RegistrationStatus = 'Registered' AND Year = 2025 AND (Semester = 'Summer' OR Semester = 'Fall')
GROUP BY 2
HAVING COUNT(SCR.StudentFK) < 15
ORDER BY 1;

-- Q7
SELECT COUNT(SCR.StudentFK), SCR.CourseFK FROM StudentCourseRegistration AS SCR
JOIN Courses AS C ON C.CoursesKey = SCR.CourseFK
WHERE RegistrationStatus = 'Waitlisted' AND Year = 2025 AND (Semester = 'Summer' OR Semester = 'Fall')
GROUP BY 2
ORDER BY 1 DESC;

-- Q8
SELECT * FROM courseschedule CS1 , courseschedule CS2
WHERE CS1.CoursesFK <> CS2.CoursesFK
AND (CS1.ClassroomFK is NOT NULL AND CS2.ClassroomFK is NOT NULL)
AND CS1.ClassRoomFK = CS2.ClassRoomFK
AND (CS1.Day = CS2.Day)
AND ((CS1.StartTime = CS2.StartTime) AND (CS2.StartTime = CS2.EndTime));

-- Q9
SELECT AVG(NUM_COURSES), Sem, Year FROM
(SELECT COUNT(SCR.CourseFK) AS NUM_COURSES, C.Semester AS Sem, C.Year AS Year, SCR.StudentFK as Student FROM Courses C
JOIN StudentCourseRegistration AS SCR ON C.CoursesKey = SCR.CourseFK
WHERE RegistrationStatus = 'Active' OR RegistrationStatus = 'Registered'
GROUP BY 2, 3, 4
ORDER BY 1 DESC) AS CoursesPerSemPerStudent
GROUP BY 2, 3
ORDER BY 1 DESC;
