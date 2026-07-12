class DeviceInfoService {
  Future<String> getDeviceModel() async {
    // In future, use device_info_plus package
    return 'Mock Device Model';
  }

  Future<String> getOsVersion() async {
    return 'Mock OS Version';
  }
}
