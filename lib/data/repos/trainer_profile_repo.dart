import 'package:eatmehv2/data/models/trainer/trainer_profile_model.dart';
import 'package:eatmehv2/data/models/user/goal_model.dart';
import 'package:eatmehv2/data/services/trainer_profile_service.dart';

class TrainerProfileRepo {
  final TrainerProfileService _trainerProfileService;
  TrainerProfileRepo(this._trainerProfileService);

  Future<void> createTrainerProfile(
    String trainerUid,
    TrainerProfile profile,
  ) async {
    return await _trainerProfileService.createTrainerProfile(
      trainerUid,
      profile,
    );
  }

  Future<TrainerProfile?> getTrainerProfile(String userUid) async {
    return await _trainerProfileService.getTrainerProfile(userUid);
  }

  Future<List<Map<String, dynamic>>> getAllTrainers() async {
    return await _trainerProfileService.getAllTrainers();
  }

  Future<void> updateTrainerProfile(
    String trainerUid,
    TrainerProfile profile,
  ) async {
    return await _trainerProfileService.updateTrainerProfile(
      trainerUid,
      profile,
    );
  }

  Stream<List<Map<String, dynamic>>> getTraineesDetailsStream(
    List<String> traineeUids,
    String trainerUid,
  ) {
    return _trainerProfileService.getTraineesDetailsStream(
      traineeUids,
      trainerUid,
    );
  }

  Future<void> acceptTraineeRequest(
    String trainerUid,
    String traineeUid,
  ) async {
    return await _trainerProfileService.acceptTraineeRequest(
      trainerUid,
      traineeUid,
    );
  }

  Future<void> declineTraineeRequest(
    String trainerUid,
    String traineeUid,
  ) async {
    return await _trainerProfileService.rejectTraineeRequest(
      trainerUid,
      traineeUid,
    );
  }

  Future<void> saveUserGoals(String traineeUid, Goal goals) async {
    return await _trainerProfileService.saveUserGoals(traineeUid, goals);
  }
}
