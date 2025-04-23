Use nthota;

ALTER TABLE CoursePreReqs
ADD CONSTRAINT chk_course_not_self_prereq
CHECK (CourseKey <> PreReqCourse);

ALTER TABLE Courses
ADD CONSTRAINT chk_course_start_before_end
CHECK (StartDate < EndDate);

ALTER TABLE Program
ADD CONSTRAINT chk_program_start_before_end
CHECK (ProgramStartDate < ProgramEndDate);

ALTER TABLE CourseSchedule
ADD CONSTRAINT chk_course_schedule_start_before_end
CHECK (StartTime < EndTime)

