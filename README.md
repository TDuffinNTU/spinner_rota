# Get Started

1. `flutter pub get`

2. `dart run build_runner build --delete-conflicting-outputs`

3. `flutter run`

# CSV schemas

## Without meta row

```
    Name(str),Nickname(str),isPresent(str: 'false':'true')
    ...
    Name(str),Nickname(str),isPresent(str: 'false':'true')

```

## *With* meta row

```
    Title(str),CurrentMeister(int)
    Name(str),Nickname(str),isPresent(str: 'false':'true')
    ...
    Name(str),Nickname(str),isPresent(str: 'false':'true')

```

CurrentMeister is a zero-based index into the list of following entries. -1 is "none" and is default if index exceeds bounds.
