# Итоговая работа по SQL

## О предметной области:
Данный проект представляет собой схему сущностей в платформе моделирования и прогнозирования экономических временных рядов

**Он включает в себя сущности:**
- **Частотность ряда** (data_frequency):
  - Годовая (Y), квартальная (Q), ежемесячная (M) или ежедневная (D)
  - На начало периода (S) или на конец (E)
- **Временной ряд** (series) с названием, частотностью ряда и его значениями
- **Единица предобработки** (preprocessing) с названием
- **Последовательность предобработок** (preprocessing_sequence) с предобработкой и его номером в последовательности
- **Признак** (features) со ссылкой на временной ряд и опциональной последовательностью предобработкой
- **Прогнозная модель** (forecast_models) с эндогенными, экзогенными переменными, псевдонимом и ссылкой на веса модели (S3)

### Диаграмма сущностей выглядит так:
```mermaid
erDiagram
    series {
        integer id PK
        text name "not null"
        integer freq_id FK "not null"
    }

    data_frequency {
        integer id PK
        varchar(2) name UK
    }

    series_values {
        integer series_id FK "not null"
        timestamp date "not null"
        float value
    }

    preprocessing {
        integer id PK
        text name "not null"
    }

    preprocessing_sequence {
        integer id PK
        integer preprocessing_id FK "not null"
        integer step "not null"
    }

    features {
        integer id PK
        text alias
        integer series_id FK "not null"
        integer preprocessing_sequence_id FK
    }

    model_types {
        integer id PK
        text name
    }

    forecast_models {
        text name "not null"
        text weight_url "not null"
        integer[] endog_var_ids "not null"
        integer[] exog_var_ids
        integer model_type_id FK "not null"
    }

    series ||--o{ series_values : "has many"
    series }|--|| data_frequency : "frequency"
    
    preprocessing ||--o{ preprocessing_sequence : "has sequence"
    preprocessing_sequence }|--|| features : "used by"
    series ||--o{ features : "has features"
    
    model_types ||--o{ forecast_models : "type of"
    features }o--o{ forecast_models : "endogenous variables"
    features }o--o{ forecast_models : "exogenous variables"
```

