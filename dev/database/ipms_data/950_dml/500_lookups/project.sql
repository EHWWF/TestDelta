ALTER TABLE project
ADD (
    DETAILS_OBJECTIVE NVARCHAR2(2000),
    DETAILS_RATIONALE NVARCHAR2(2000),	
    DETAILS_SCOPE NVARCHAR2(2000),
    DETAILS_INTENDED_USE NVARCHAR2(2000),
	DETAILS_BENEFITS NVARCHAR2(2000),
    DETAILS_EXECUTIVE_SUMMARY NVARCHAR2(2000),	
	DETAILS_RISKS NVARCHAR2(2000),
    DETAILS_HIGHLIGHTS NVARCHAR2(2000),
	DETAILS_ACTIVITIES_EVENTS NVARCHAR2(2000),
    DETAILS_BUDGET NVARCHAR2(2000),	
	DETAILS_SAMD_STATUS NVARCHAR2(100),
    DETAILS_BUDGET_STATUS NVARCHAR2(100)
);
