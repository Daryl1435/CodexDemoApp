# Firestore Schema Design

The following collections support classes, notes, questions, and users for the learning app. Each example shows representative document structures with key references.

## Collections Overview

- `users`
- `classes`
  - Subcollection: `notes`
  - Subcollection: `questions`
- `enrollments` *(optional helper collection for analytics)*

## `users` Collection

```json
{
  "users": {
    "uid_123": {
      "displayName": "Avery Johnson",
      "email": "avery@example.com",
      "role": "student",          // enum: student | teacher | admin
      "photoURL": "https://.../avery.jpg",
      "createdAt": "2023-08-01T12:45:20.000Z",
      "enrolledClassIds": ["class_astro101", "class_math201"],
      "teachingClassIds": ["class_astro101"],
      "preferences": {
        "darkMode": true,
        "notificationChannels": ["email", "push"]
      }
    }
  }
}
```

## `classes` Collection

```json
{
  "classes": {
    "class_astro101": {
      "title": "Introduction to Astronomy",
      "description": "Survey of stellar evolution, galaxies, and cosmology.",
      "code": "ASTRO-101",
      "ownerUserId": "uid_999",
      "instructorIds": ["uid_999", "uid_123"],
      "studentIds": ["uid_555", "uid_123"],
      "schedule": {
        "startDate": "2024-01-08",
        "endDate": "2024-05-15",
        "meetingTimes": [
          { "day": "Monday", "start": "14:00", "end": "15:15" },
          { "day": "Wednesday", "start": "14:00", "end": "15:15" }
        ]
      },
      "tags": ["science", "astronomy"],
      "createdAt": "2023-12-05T18:10:00.000Z",
      "updatedAt": "2024-01-15T16:42:12.000Z"
    }
  }
}
```

### `classes/{classId}/notes` Subcollection

Notes belong to a specific class and can optionally be authored by a user.

```json
{
  "classes/class_astro101/notes": {
    "note_001": {
      "title": "Lifecycle of Stars",
      "content": "Massive stars evolve through supernova events...",
      "authorUserId": "uid_999",
      "visibility": "class",          // enum: class | instructor | private
      "attachments": [
        {
          "type": "image",
          "storagePath": "classes/class_astro101/notes/note_001/nebula.jpg",
          "caption": "Crab Nebula image"
        }
      ],
      "createdAt": "2024-02-03T09:32:11.000Z",
      "updatedAt": "2024-02-05T10:05:00.000Z"
    }
  }
}
```

### `classes/{classId}/questions` Subcollection

Questions allow threaded discussion attached to a class.

```json
{
  "classes/class_astro101/questions": {
    "question_778": {
      "title": "Why do some stars become neutron stars?",
      "body": "I'm confused about the role of stellar mass...",
      "authorUserId": "uid_555",
      "status": "open",               // enum: open | answered | archived
      "tags": ["stellar evolution", "neutron stars"],
      "upvoteUserIds": ["uid_123", "uid_999"],
      "answerCount": 2,
      "createdAt": "2024-02-12T18:21:00.000Z",
      "updatedAt": "2024-02-13T08:12:45.000Z"
    }
  }
}
```

Add an optional `answers` subcollection when you need threaded replies:

```json
{
  "classes/class_astro101/questions/question_778/answers": {
    "answer_001": {
      "authorUserId": "uid_999",
      "body": "Massive stars collapse into neutron stars when...",
      "isAccepted": true,
      "upvoteUserIds": ["uid_555"],
      "createdAt": "2024-02-12T19:05:37.000Z"
    }
  }
}
```

## `enrollments` Collection *(Optional)*

This collection is helpful for querying relationships without loading entire user or class documents.

```json
{
  "enrollments": {
    "uid_123__class_astro101": {
      "userId": "uid_123",
      "classId": "class_astro101",
      "role": "student",
      "joinedAt": "2024-01-02T14:22:00.000Z",
      "progress": {
        "completedNotes": 5,
        "questionsAsked": 3
      }
    }
  }
}
```

## Security & Indexing Notes

- Use Firestore security rules to ensure only instructors modify class-level resources, while students can add questions and personal notes.
- Create composite indexes for frequent queries such as `questions` ordered by `createdAt` filtered by `status` and `tags`.
- Store timestamps using Firestore `Timestamp` fields to preserve ordering semantics.
