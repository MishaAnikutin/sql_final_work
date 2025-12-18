-- Частоты дат
INSERT INTO 
	data_frequency (name)
VALUES
	('D'),
	('MS'),
	('QS'),
	('YS'),
	('ME'),
	('QE'),
	('YE');

-- Типы моделей
INSERT INTO
	model_types (name)
VALUES
	('ARIMAX'),
	('VAR'),
	('GARCH'),
	('CatBoost'),
	('LSTM');
