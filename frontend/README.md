# frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Windows build note (NuGet)

If you repeatedly see the message:

```
Nuget.exe not found, trying to download or use cached version.
```

This is informational. To make it disappear and speed up Windows builds:

1. Create a tools directory and download nuget.exe:
	```powershell
	New-Item -ItemType Directory -Force -Path C:\tools\nuget
	Invoke-WebRequest -Uri https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile C:\tools\nuget\nuget.exe
	```
2. Add it permanently to PATH:
	```powershell
	setx PATH "$($env:PATH);C:\tools\nuget"
	```
3. Open a new PowerShell and verify:
	```powershell
	where nuget
	```
4. Rebuild:
	```powershell
	flutter clean
	flutter build windows
	```

Optional: run the helper script in `scripts/setup_nuget.ps1`.

If `flutter doctor` reports missing Visual Studio components, install the workload "Desktop development with C++" and Windows 10/11 SDK.

