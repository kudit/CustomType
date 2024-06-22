# ChangeLog

NOTE: Version needs to be updated in the following places:
- [ ] Xcode project version (in build settings - normal and watch targets should inherit)
- [ ] Package.swift iOSApplication product displayVersion.
- [ ] CustomType.version constant (must be hard coded since inaccessible in code)
- [ ] Tag with matching version in GitHub.


v1.0.0 6/22/2024 Initial Project for simplifying code in ParticleEffects package (but likely can be used elsewhere).

## Bugs to fix:
Known issues that need to be addressed.

- [ ] None so far!

## Roadmap:
Planned features and anticipated API changes.  If you want to contribute, this is a great place to start.

- [ ] Create so that we have a simple way of creating custom types using enum syntax for presets but that can store any value of the base type.

## Proposals:
This is where proposals can be discussed for potential movement to the roadmap.

- [ ] Have a way to toll-free bridge to the base type so can use without pulling the rawValue.
