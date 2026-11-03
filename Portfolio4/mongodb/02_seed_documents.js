
// Portfolio 4: reproducible sample student profile documents.
// These are synthetic coursework records.

const profiles = db.getSiblingDB("mun_srrms_nosql").student_profiles;

const samples = [
  {
    matric_number: "MUN/2026/0001",
    profile: {
      first_name: "Ada",
      last_name: "Okafor",
      display_name: "Ada O.",
      programme: {
        programme_code: "MIT",
        programme_name: "MSc Information Technology"
      }
    },
    preferences: {
      notification_channels: ["email", "in_app"],
      language: "en",
      accessibility: []
    },
    learning_activity: [
      {
        activity_type: "resource_view",
        course_code: "MIT8101",
        occurred_at: ISODate("2026-10-01T10:00:00Z"),
        metadata: {
          resource_type: "lecture_note",
          duration_seconds: 420
        }
      },
      {
        activity_type: "quiz_attempt",
        course_code: "MIT8101",
        occurred_at: ISODate("2026-10-03T14:30:00Z"),
        metadata: {
          attempt_number: 1
        }
      }
    ],
    updated_at: ISODate("2026-10-05T00:00:00Z")
  },
  {
    matric_number: "MUN/2026/0002",
    profile: {
      first_name: "Chidi",
      last_name: "Bello",
      display_name: "Chidi B.",
      programme: {
        programme_code: "MIT",
        programme_name: "MSc Information Technology"
      }
    },
    preferences: {
      notification_channels: ["sms", "in_app"],
      language: "en",
      accessibility: ["high_contrast"]
    },
    learning_activity: [
      {
        activity_type: "forum_post",
        course_code: "MIT8102",
        occurred_at: ISODate("2026-10-04T09:15:00Z"),
        metadata: {
          discussion_topic: "database-design"
        }
      }
    ],
    updated_at: ISODate("2026-10-05T00:00:00Z")
  }
];

let inserted = 0;
let alreadyPresent = 0;

for (const doc of samples) {
  const result = profiles.updateOne(
    { matric_number: doc.matric_number },
    { $setOnInsert: doc },
    { upsert: true }
  );

  if (result.upsertedCount === 1) {
    inserted++;
  } else {
    alreadyPresent++;
  }
}

print("New sample profiles inserted: " + inserted);
print("Existing sample profiles preserved: " + alreadyPresent);
print("Total profiles in collection: " + profiles.countDocuments({}));
