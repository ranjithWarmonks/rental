# Design Reference

All UI designs and feature implementations must refer to the official Stitch design project:
- **Stitch Design Link:** https://stitch.withgoogle.com/projects/7993474546635576006

---

# Feature Architecture

Every feature must follow the same directory structure:

```text
lib/
└── features/
    ├── auth/
    │   ├── models/
    │   ├── views/
    │   ├── controllers/
    │   └── services/
    │
    ├── home/
    │   ├── models/
    │   ├── views/
    │   ├── controllers/
    │   └── services/
    │
    └── rentals/
        ├── models/
        ├── views/
        ├── controllers/
        └── services/
```

## Feature Directory Responsibilities

### `models/`

Contains feature-specific data models.

Examples:

```text
rental_item_model.dart
rental_order_model.dart
customer_model.dart
```

Models are responsible for:

* Data structures
* JSON serialization
* JSON deserialization
* Domain data

---

### `views/`

Contains feature-specific UI screens and widgets.

Examples:

```text
rentals_view.dart
rental_detail_view.dart
rental_checkout_view.dart
```

Views are responsible for:

* UI
* Widget composition
* User interaction
* Displaying BLoC state

Views must not contain:

* API calls
* Business logic
* Pricing calculations
* Availability logic
* Direct service calls

---

### `controllers/`

Contains the feature's **BLoC state-management files**.

BLoC is the **only feature state-management solution**.

Example:

```text
controllers/
├── rental_bloc.dart
├── rental_event.dart
└── rental_state.dart
```

Responsibilities:

```text
rental_event.dart
    ↓
User/application actions

rental_bloc.dart
    ↓
State management
Business workflow
Service coordination

rental_state.dart
    ↓
Current feature state
```

Do not use Cubit.

Do not introduce another state-management solution.

---

### `services/`

Contains feature-specific services.

Examples:

```text
rental_service.dart
```

Services are responsible for:

* API calls
* Backend communication
* Data retrieval
* External services

Services must not manage UI state.

---

# Example: Rentals Feature

The rentals feature must follow the same structure as every other feature:

```text
lib/
└── features/
    └── rentals/
        ├── models/
        │   ├── rental_item_model.dart
        │   └── rental_order_model.dart
        │
        ├── views/
        │   ├── rentals_view.dart
        │   ├── rental_detail_view.dart
        │   └── rental_checkout_view.dart
        │
        ├── controllers/
        │   ├── rental_bloc.dart
        │   ├── rental_event.dart
        │   └── rental_state.dart
        │
        └── services/
            └── rental_service.dart
```

The important rule is that **every feature uses the same four top-level directories**:

```text
models/
views/
controllers/
services/
```

Do not create feature-specific alternatives such as:

```text
bloc/
cubit/
repositories/
providers/
state/
```

unless those directories already exist as part of the repository's established architecture.

---

# BLoC Placement Rule

Because this project uses BLoC, BLoC files belong inside the feature's existing `controllers/` directory.

Correct:

```text
features/
└── rentals/
    └── controllers/
        ├── rental_bloc.dart
        ├── rental_event.dart
        └── rental_state.dart
```

Incorrect:

```text
features/
└── rentals/
    └── bloc/
        └── rental_bloc.dart
```

Incorrect:

```text
features/
└── rentals/
    └── cubit/
```

Incorrect:

```text
features/
└── rentals/
    └── state/
```

---

# Standard Feature Template

When creating a new feature, start from:

```text
lib/
└── features/
    └── <feature>/
        ├── models/
        ├── views/
        ├── controllers/
        └── services/
```

For example:

```text
lib/features/products/
├── models/
├── views/
├── controllers/
└── services/
```

If BLoC is required:

```text
lib/features/products/
├── models/
├── views/
├── controllers/
│   ├── product_bloc.dart
│   ├── product_event.dart
│   └── product_state.dart
└── services/
```

Do not add unnecessary directories.

---

# Feature Data Flow

The architecture remains:

```text
View
  ↓
Event
  ↓
BLoC
  ↓
Service
  ↓
API / Backend
  ↓
Model
  ↓
BLoC
  ↓
State
  ↓
View
```

This structure applies consistently to:

* `auth`
* `home`
* `rentals`
* `products`
* `customers`
* `orders`
* Any future feature

**Never invent a different folder architecture for a new feature.**

---

# Shared Reusable Widgets Rule

All UI components that are shared across multiple features (e.g., custom Text, TextFormField, Buttons, Dialog Boxes, Cards, and Status Badges) **must reside inside `lib/shared/widgets/`**.

Example directory structure:

```text
lib/
└── shared/
    └── widgets/
        ├── app_text.dart
        ├── app_text_field.dart
        ├── app_button.dart
        ├── app_dialog.dart
        └── app_status_badge.dart
```

Responsibilities:
* `app_text.dart`: Standardized typography widget (`Urbanist` font).
* `app_text_field.dart`: Standardized text input field with required field indicators (`*`), icons, placeholders, and validation.
* `app_button.dart`: Standardized primary (`#059669`), secondary (`#0F172A`), outlined, and icon buttons with loading state support.
* `app_dialog.dart`: Standardized alert, confirmation, and action dialog boxes.
* `app_status_badge.dart`: Standardized status pill badge (`Active`, `Due Today`, `Overdue`, `Returned`).

Never duplicate core input fields, buttons, or dialog implementations inside individual feature views.

