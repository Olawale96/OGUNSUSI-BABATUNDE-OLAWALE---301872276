
const profiles = db.getSiblingDB("mun_srrms_nosql").student_profiles;
const demoMatric = "MUN/DEMO/9001";

// Remove only this script's reserved demonstration document.
// This makes the CRUD demonstration safe to repeat.
const previousDemo = profiles.deleteOne({
  matric_number: demoMatric
});
print("Previous demonstration document removed: " + previousDemo.deletedCount);

// READ: find one profile using the cross-database business identifier.
print("READ: Existing student profile");
printjson(profiles.findOne(
  { matric_number: "MUN/2026/0001" },
  { _id: 0, matric_number: 1, profile: 1, preferences: 1 }
));

// CREATE: add a dedicated demonstration profile.
const createResult = profiles.insertOne({
  matric_number: demoMatric,
  profile: {
    first_name: "Test",
    last_name: "Student",
    display_name: "Test Student",
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
});

print("CREATE result:");
printjson(createResult);

// UPDATE: change preferences and append a learning activity.
const updateResult = profiles.updateOne(
  { matric_number: demoMatric },
  {
    $set: {
      "preferences.notification_channels": ["email", "in_app"],
      updated_at: new Date()
    },
    $push: {
      learning_activity: {
        activity_type: "resource_view",
        course_code: "MIT8101",
        occurred_at: new Date(),
        metadata: {
          resource_type: "demo_resource"
        }
      }
    }
  }
);

print("UPDATE result:");
printjson(updateResult);

// READ AFTER UPDATE.
print("READ AFTER UPDATE:");
printjson(profiles.findOne({
  matric_number: demoMatric
}));

// DELETE only the reserved demonstration document.
const deleteResult = profiles.deleteOne({
  matric_number: demoMatric
});

print("DELETE result:");
printjson(deleteResult);

print("Remaining profile count: " + profiles.countDocuments({}));
