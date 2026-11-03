const c = db.getCollection("student_profiles");

print("=== DOCUMENT COUNT ===");
print(c.countDocuments({}));

print("=== STUDENT PROFILES ===");
printjson(
  c.find(
    {},
    {
      _id: 0,
      matric_number: 1,
      profile: 1,
      preferences: 1
    }
  ).toArray()
);

print("=== INDEX DEFINITIONS ===");
printjson(c.getIndexes());

print("=== BSON DATE VERIFICATION ===");
printjson(
  c.aggregate([
    {
      $project: {
        _id: 0,
        matric_number: 1,
        updated_at_type: { $type: "$updated_at" },
        activity_count: { $size: "$learning_activity" }
      }
    }
  ]).toArray()
);
