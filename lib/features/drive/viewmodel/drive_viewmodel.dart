
import 'package:googleapis/drive/v2.dart' as googlrDrive;

import '../data/drive_repository.dart';


class DriveState {
  final List<googlrDrive.File>? files;
  final bool isLoading;
  final String? error;

  DriveState({required this.files, required this.isLoading, this.error});

  factory DriveState.initial() =>
      DriveState(files: [], isLoading: false, error: null);
}


class DriveViewModel {
  final DriveRepository _driveRepository;


  DriveViewModel(this._driveRepository);


  void fetchDriveFileList(){
    _driveRepository.getDriveFileList();
  }
}