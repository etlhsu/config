# Kotlin Scripting Tips

## Basics
```kotlin
#!/usr/bin/env kotlin

```

## Java Core
```kotlin
import java.util.Calendar
Calendar.getInstance().getTimeInMillis() // Get current time in millis

Runtime.getRuntime.exec("echo hello") // Execute command

val proc = Runtime.getRuntime.exec("ls").also(Process::waitFor) // Execute command and read output
val stdOut = proc.getInputStream().reader().readLines();
val stdErr = proc.getErrorStream().reader().readLines();
val code = proc.exitValue()
```
