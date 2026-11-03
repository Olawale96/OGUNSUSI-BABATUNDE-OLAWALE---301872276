const profiles = db.getSiblingDB("mun_srrms_nosql").student_profiles;
const testKey = "MUN/TEST/UNIQUE-INDEX-9001";

// Remove only a leftover document from this reserved test.
profiles.deleteMany({ matric_number: testKey });

const testDocument = {
  matric_number: testKey,
  profile: {
    first_name: "Unique",
    last_name: "Tester",
    programme: {
      programme_code: "MIT",
      programme_name: "MSc Information Technology"
    }
  },
  preferences: {
    notification_channels: ["in_app"],
    language: "en",
    accessibility: []
  },
  learning_activity: [],
  updated_at: new Date()
};

const first = profiles.insertOne(testDocument);
print("First test document inserted: " + first.acknowledged);

let duplicateRejected = false;

try {
  profiles.insertOne(testDocument);
  print("FAIL: duplicate matriculation number was accepted.");
} catch (error) {
  if (error.code === 11000) {
    duplicateRejected = true;
    print("PASS: duplicate matriculation number rejected.");
    print("MongoDB duplicate-key error code: " + error.code);
  } else {
    throw error;
  }
}

const cleanup = profiles.deleteMany({ matric_number: testKey });
print("Temporary test documents removed: " + cleanup.deletedCount);

if (!duplicateRejected) {
  throw new Error("Unique-index test failed.");
}

print("Final profile count: " + profiles.countDocuments({}));
print("UNIQUE INDEX TEST PASSED.");
