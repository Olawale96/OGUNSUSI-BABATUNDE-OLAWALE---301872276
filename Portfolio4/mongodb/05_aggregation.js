const profiles = db.getSiblingDB("mun_srrms_nosql").student_profiles;

// Unwind embedded learning activity, group by course and activity type.
// The sample dataset is deliberately small; this demonstrates aggregation
// structure, not a meaningful performance benchmark.
const pipeline = [
  { $unwind: "$learning_activity" },
  {
    $group: {
      _id: {
        course_code: "$learning_activity.course_code",
        activity_type: "$learning_activity.activity_type"
      },
      event_count: { $sum: 1 }
    }
  },
  {
    $project: {
      _id: 0,
      course_code: "$_id.course_code",
      activity_type: "$_id.activity_type",
      event_count: 1
    }
  },
  { $sort: { course_code: 1, activity_type: 1 } }
];

printjson(profiles.aggregate(pipeline).toArray());
