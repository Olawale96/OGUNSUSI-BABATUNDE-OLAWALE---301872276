// Portfolio 4: create and validate the student profile collection.
// Database: mun_srrms_nosql

const targetDb = db.getSiblingDB("mun_srrms_nosql");

const validator = {
  $jsonSchema: {
    bsonType: "object",
    required: [
      "matric_number",
      "profile",
      "preferences",
      "learning_activity",
      "updated_at"
    ],
    additionalProperties: false,
    properties: {
      _id: { bsonType: "objectId" },

      matric_number: {
        bsonType: "string",
        minLength: 1,
        pattern: ".*\\S.*"
      },

      profile: {
        bsonType: "object",
        required: ["first_name", "last_name", "programme"],
        additionalProperties: false,
        properties: {
          first_name: {
            bsonType: "string",
            minLength: 1,
            pattern: ".*\\S.*"
          },
          last_name: {
            bsonType: "string",
            minLength: 1,
            pattern: ".*\\S.*"
          },
          display_name: { bsonType: "string" },
          programme: {
            bsonType: "object",
            required: ["programme_code", "programme_name"],
            additionalProperties: false,
            properties: {
              programme_code: {
                bsonType: "string",
                minLength: 1,
                pattern: ".*\\S.*"
              },
              programme_name: {
                bsonType: "string",
                minLength: 1,
                pattern: ".*\\S.*"
              }
            }
          }
        }
      },

      preferences: {
        bsonType: "object",
        required: ["notification_channels", "language"],
        additionalProperties: false,
        properties: {
          notification_channels: {
            bsonType: "array",
            items: { enum: ["email", "sms", "in_app"] }
          },
          language: {
            bsonType: "string",
            minLength: 1,
            pattern: ".*\\S.*"
          },
          accessibility: {
            bsonType: "array",
            items: { bsonType: "string" }
          }
        }
      },

      learning_activity: {
        bsonType: "array",
        maxItems: 20,
        items: {
          bsonType: "object",
          required: ["activity_type", "course_code", "occurred_at"],
          additionalProperties: false,
          properties: {
            activity_type: {
              enum: ["resource_view", "quiz_attempt", "forum_post"]
            },
            course_code: {
              bsonType: "string",
              minLength: 1,
              pattern: ".*\\S.*"
            },
            occurred_at: { bsonType: "date" },
            metadata: { bsonType: "object" }
          }
        }
      },

      updated_at: { bsonType: "date" }
    }
  }
};

const existing = targetDb.getCollectionInfos({
  name: "student_profiles"
}).length > 0;

if (!existing) {
  targetDb.createCollection("student_profiles", {
    validator: validator,
    validationLevel: "strict",
    validationAction: "error"
  });

  print("Created student_profiles with strict JSON Schema validation.");
} else {
  const result = targetDb.runCommand({
    collMod: "student_profiles",
    validator: validator,
    validationLevel: "strict",
    validationAction: "error"
  });

  if (!result.ok) {
    throw new Error("Could not update collection validator.");
  }

  print("Updated student_profiles validator.");
}

const profiles = targetDb.getCollection("student_profiles");

// Enforce the business identifier before sample data is inserted.
profiles.createIndex(
  { matric_number: 1 },
  { unique: true, name: "uq_matric_number" }
);

print("Unique matric_number index verified.");
print("Collection validation configuration:");
printjson(targetDb.getCollectionInfos({
  name: "student_profiles"
}));