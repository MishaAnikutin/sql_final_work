-- Временные ряды
CREATE TABLE data_frequency (
    id SERIAL PRIMARY KEY,
    name VARCHAR(2) UNIQUE NOT NULL CHECK (name IN ('MS', 'QS', 'YS', 'D', 'ME', 'QE', 'YE'))
);

CREATE TABLE series (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    freq_id INTEGER NOT NULL REFERENCES data_frequency(id)
);

CREATE TABLE series_values (
    series_id INTEGER NOT NULL REFERENCES series(id),
    date TIMESTAMP NOT NULL,
    value FLOAT,
    PRIMARY KEY (series_id, date)
);

-- Предобработка
CREATE TABLE preprocessing (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE preprocessing_sequence (
    id SERIAL PRIMARY KEY,
    preprocessing_id INTEGER NOT NULL REFERENCES preprocessing(id),
    step INTEGER NOT NULL CHECK (step > 0),
    UNIQUE(preprocessing_id, step)
);

CREATE TABLE features (
    id SERIAL PRIMARY KEY,
    alias TEXT,
    series_id INTEGER NOT NULL REFERENCES series(id),
    preprocessing_sequence_id INTEGER REFERENCES preprocessing_sequence(id)
);

-- Прогнозные модели
CREATE TABLE model_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

CREATE TABLE forecast_models (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    weight_url TEXT NOT NULL,
    model_type_id INTEGER NOT NULL REFERENCES model_types(id)
);


CREATE TABLE model_endog_vars (
    model_id INTEGER NOT NULL REFERENCES forecast_models(id),
    feature_id INTEGER NOT NULL REFERENCES features(id),
    PRIMARY KEY (model_id, feature_id)
);

CREATE TABLE model_exog_vars (
    model_id INTEGER NOT NULL REFERENCES forecast_models(id),
    feature_id INTEGER NOT NULL REFERENCES features(id),
    PRIMARY KEY (model_id, feature_id)
);

