-- 1. Tác động của Overtime đến tỷ lệ nghỉ việc theo từng phòng ban ?
SELECT
	department,
	CASE WHEN overtime = 1 THEN 'Yes' ELSE 'No' END AS is_overtime,
	COUNT(*) AS total_employees,
	SUM(attrition) AS churned_employees,
	ROUND(AVG(attrition) * 100.0, 2) AS attrition_rate_pct
FROM hr_analytics_cleaned
GROUP BY department, overtime
ORDER BY department, is_overtime DESC;

-- 2. Mỗi liên hệ giữa số năm làm việc với Quản lý trực tiếp và nguy cơ nghỉ việc
SELECT
	CASE
		WHEN yearswithcurrmanager = 0 THEN 'Dưới 1 năm (Năm đầu)'
		WHEN yearswithcurrmanager BETWEEN 1 AND 2 THEN '1 - 2 năm'
		WHEN yearswithcurrmanager BETWEEN 3 AND 5 THEN '3 - 5 năm'
	ELSE 'Trên 5 năm'
	END AS manager_tenure_group,
	COUNT(*) AS employee_count,
	ROUND(AVG(attrition) * 100.0, 2) AS attrition_rate_pct
FROM hr_analytics_cleaned
GROUP BY 1
ORDER BY attrition_rate_pct DESC;

-- 3. Phân tích khoảng cách thu nhập theo giới tính (Gender Pay Gap) ở từng vị trí

WITH salary AS (
    SELECT
        jobrole,
        AVG(monthlyincome) FILTER (WHERE gender = 'Male') AS male_income,
        AVG(monthlyincome) FILTER (WHERE gender = 'Female') AS female_income
    FROM hr_analytics_cleaned
    GROUP BY jobrole
)
SELECT
    jobrole,
    ROUND(male_income) AS male_avg_income,
    ROUND(female_income) AS female_avg_income,
    ROUND((male_income - female_income) * 100 / NULLIF(female_income, 0), 2) AS pay_gap_pct
FROM salary
ORDER BY ABS((male_income - female_income) / NULLIF(female_income, 0)) DESC;

-- 4. Nhận diện "Điểm nóng" nhân viên nghỉ việc do Đi công tác & Mất cân bằng cuộc sống
SELECT
	businesstravel,
	worklifebalance,
	COUNT(*) AS total_staff,
	ROUND(AVG(attrition) * 100.0, 2) AS attrition_rate_pct
FROM hr_analytics_cleaned
GROUP BY businesstravel, worklifebalance
HAVING COUNT(*) >= 10
ORDER BY attrition_rate_pct DESC
LIMIT 5;
-- 5. Thâm niên không được thăng thức (Promotion Stagnation) và mức độ hài lòng
SELECT
	CASE
		WHEN yearssincelastpromotion = 0 THEN 'Mới thăng chức (0 năm)'
		WHEN yearssincelastpromotion BETWEEN 1 AND 3 THEN '1 - 3 năm'
		WHEN yearssincelastpromotion BETWEEN 4 AND 7 THEN '4 - 7 năm'
		ELSE 'Trên 7 năm (Bị trì trệ)'
	END AS promotion_bucket,
	COUNT(*) AS total_staff,
	ROUND(AVG(attrition) * 100.0, 2) AS attrition_rate_pct,
	ROUND(AVG(CAST(jobsatisfaction AS INT)), 2) AS avg_job_satisfaction
FROM hr_analytics_cleaned
GROUP BY 1
ORDER BY promotion_bucket;

-- 6. Phân tích Tứ phân vị Thu nhập (Income Quartile) trong từng Cấp bậc công việc
WITH q AS (
    SELECT *,
           NTILE(4) OVER (PARTITION BY joblevel ORDER BY monthlyincome) AS quartile
    FROM hr_analytics_cleaned
)
SELECT
    joblevel,
    quartile,
    COUNT(*) AS total_staff,
    ROUND(AVG(monthlyincome)) AS avg_income,
    ROUND(AVG(attrition) * 100, 2) AS attrition_rate_pct
FROM q
WHERE joblevel IN ('1', '2')
GROUP BY joblevel, quartile
ORDER BY joblevel, quartile;
-- 7. Nghịch lý giữ chân Nhân sự Hiệu suất xuất sắc (Top Performers Flight Risk)
SELECT
	performancerating,
	CASE
		WHEN percentsalaryhike < 22 THEN 'Tăng lương tiêu chuẩn (< 22%)'
		ELSE
FROM hr_analytics_cleaned

-- 8. Thói quen nhảy việc (Job Hoppers) và Tốc độ gia tăng thu nhập
