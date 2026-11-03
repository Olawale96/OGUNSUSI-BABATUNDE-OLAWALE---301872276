const profiles = db.getSiblingDB("mun_srrms_nosql").student_profiles;

// Unique business key: one profile per matriculation number.
profiles.createIndex({ matric_number: 1 }, { unique: true, name: "uq_matric_number" });

// Support filtering profiles by programme code.
profiles.createIndex(
  { "profile.programme.programme_code": 1 },
  { name: "idx_programme_code" }
);

// Query examples.
print("Profile by matriculation number:");
printjson(profiles.find(
  { matric_number: "MUN/2026/0001" },
  { _id: 0, matric_number: 1, "profile.display_name": 1 }
).toArray());

print("Profiles in MIT programme:");
printjson(profiles.find(
  { "profile.programme.programme_code": "MIT" },
  { _id: 0, matric_number: 1, "profile.programme": 1 }
).toArray());

print("Index definitions:");
printjson(profiles.getIndexes());

// Explain a representative query; record the actual plan from your environment.
printjson(profiles.find(
  { matric_number: "MUN/2026/0001" }
).explain("executionStats"));
