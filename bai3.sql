USE rikkeiclinicdb;

DROP PROCEDURE IF EXISTS DispenseMedicine;

DELIMITER //
CREATE PROCEDURE DispenseMedicine(
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT,
    OUT p_status_message VARCHAR(250)
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(18,2);
    START TRANSACTION;
    SELECT stock, price 
    INTO v_stock, v_price 
    FROM Medicines 
    WHERE medicine_id = p_medicine_id;
    IF v_stock < p_quantity THEN
        ROLLBACK;
        SET p_status_message = 'Số lượng tồn kho không đủ';
    ELSE
        UPDATE Medicines 
        SET stock = stock - p_quantity 
        WHERE medicine_id = p_medicine_id;

        UPDATE Patient_Invoices 
        SET total_due = total_due + (p_quantity * v_price) 
        WHERE patient_id = p_patient_id;
        COMMIT;
        SET p_status_message = 'Cấp thành công';
    END IF;
END //
DELIMITER ;


CALL DispenseMedicine(1, 2, 2, @message1);
SELECT @message1 AS KetQua_Case1;

SELECT * FROM Medicines WHERE medicine_id = 2;
SELECT * FROM Patient_Invoices WHERE patient_id = 1;

CALL DispenseMedicine(1, 2, 10, @message2);
SELECT @message2 AS KetQua_Case2;

SELECT * FROM Medicines WHERE medicine_id = 2;
SELECT * FROM Patient_Invoices WHERE patient_id = 1;