const profiles = db.getSiblingDB("mun_srrms_nosql").student_profiles;

const baseDocument = {
  matric_number: "MUN/TEST/VALIDATION",
  profile: {
    first_name: "Validation",
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

const cases = [
  {
    name: "Whitespace-only matriculation number",
    document: {
      ...baseDocument,
      matric_number: "   "
    }
  },
  {
    name: "Unexpected top-level field",
    document: {
      ...baseDocument,
      matric_number: "MUN/TEST/EXTRA",
      unexpected_field: "not permitted"
    }
  },
  {
    name: "Unsupported notification channel",
    document: {
      ...baseDocument,
      matric_number: "MUN/TEST/CHANNEL",
      preferences: {
        notification_channels: ["pager"],
        language: "en",
        accessibility: []
      }
    }
  },
  {
    name: "Unexpected nested profile field",
    document: {
      ...baseDocument,
      matric_number: "MUN/TEST/NESTED",
      profile: {
        ...baseDocument.profile,
        unknown_attribute: "not permitted"
      }
    }
  }
];

let passed = 0;
let unexpected = 0;

print("=== MONGODB DOCUMENT VALIDATION TESTS ===");

for (const test of cases) {
  try {
    profiles.insertOne(test.document);
    print("FAIL: Document unexpectedly accepted: " + test.name);
    unexpected++;
  } catch (error) {
    if (error.code === 121) {
      print("PASS: Document rejected: " + test.name);
      print("Validation error code: " + error.code);
      passed++;
    } else {
      print("ERROR: " + test.name + ": " + error.message);
      unexpected++;
    }
  }
}

print("=== VALIDATION TEST SUMMARY ===");
print("Rejected invalid documents: " + passed);
print("Unexpected outcomes: " + unexpected);
print("Final profile count: " + profiles.countDocuments({}));

if (passed !== cases.length || unexpected !== 0) {
  throw new Error("One or more validation tests did not pass.");
}

print("ALL VALIDATION TESTS PASSED.");
