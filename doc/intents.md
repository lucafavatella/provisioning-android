# Intents

## Command line tools

### Outline

- Intent resolvers can be dumped.
  No tools are known for dumping MIME type(&subtype) schemas
  i.e. extra key-value pairs.

- Intents, both explicit and implicit, can be triggered.

### `adb shell dumpsys package resolvers`

```
$ adb shell dumpsys package -h
Package manager dump options:
  [-h] [-f] [--checkin] [cmd] ...
    --checkin: dump for a checkin
    -f: print details of intent filters
    -h: print this help
  cmd may be one of:
    ...
    r[esolvers] [activity|service|receiver|content]: dump intent resolvers
    ...
```

Dump:
- MIME type(&subtype) names.
- Component names.
- Actions.
- Categories.

### `adb shell am`

From https://developer.android.com/studio/command-line/adb#am :

> ### Call activity manager (`am`)
>
> | Command                         |                                              |
> | -                               | -                                            |
> | `start [options] intent`        | Start an Activity specified by `intent`. ... |
> | `startservice [options] intent` | Start the Service specified by `intent`. ... |
> | `broadcast [options] intent`    | Issue a broadcast intent. ...                |
>
> #### Specification for intent arguments
>
> `-a action`
>
> Specify the intent action, such as `android.intent.action.VIEW`. You can declare this only once.
>
> `-d data_uri`
>
> Specify the intent data URI, such as `content://contacts/people/1`. You can declare this only once.
>
> `-t mime_type`
>
> Specify the intent MIME type, such as `image/png`. You can declare this only once.
>
> `-c category`
>
> Specify an intent category, such as `android.intent.category.APP_CONTACTS`.
>
> `-n component`
>
> Specify the component name with package name prefix to create an explicit intent, such as `com.example.app/.ExampleActivity`.
>
> `-f flags`
>
> Add flags to the intent, as supported by [`setFlags()`](https://developer.android.com/reference/android/content/Intent#setFlags(int)).
>
> ...
>
> `-e | --es extra_key extra_string_value`
>
> `--ez extra_key extra_boolean_value`
>
> `--ei extra_key extra_int_value`
>
> `--el extra_key extra_long_value`
>
> `--ef extra_key extra_float_value`
>
> `--eu extra_key extra_uri_value`
>
> `--ecn extra_key extra_component_name_value`
>
> `--e[ilf]a extra_key extra_..._value[,extra_..._value...]`
>
> ...

## Specifications

### Intent Resolution

From https://developer.android.com/reference/android/content/Intent :

> An intent is an abstract description of an operation to be performed. It can be used ... to launch an `Activity`, ... to send it to any interested `BroadcastReceiver` components, and ... to communicate with a background `Service`.
>
> ...
>
> ## Intent Structure
>
> The primary pieces of information in an intent are:
> - action -- The general action to be performed ...
> - data -- The data to operate on ... expressed as a `Uri`.
>
> ...
>
> ... there are a number of secondary attributes ...:
> - category -- Gives additional information about the action to execute. ...
> - type -- Specifies an explicit type (a MIME type) of the intent data. Normally the type is inferred from the data itself. By setting this attribute, you disable that evaluation and force an explicit type.
> - component -- Specifies an explicit name of a component class to use for the intent. Normally this is determined by looking at the other information in the intent (the action, data/type, and categories) and matching that with a component that can handle it. If this attribute is set then none of the evaluation is performed, and this component is used exactly as is. By specifying this attribute, all of the other Intent attributes become optional.
> - extras -- This is a Bundle of any additional information. This can be used to provide extended information to the component. ...
>
> ...
>
> There are a variety of standard Intent action and category constants defined in the Intent class, but applications can also define their own. ...
>
> ## Intent Resolution
>
> There are two primary forms of intents you will use.
> - Explicit Intents have specified a component ... which provides the exact class to be run. ...
> - Implicit Intents have not specified a component; instead, they must include enough information for the system to determine which of the available components is best to run for that intent.
>
> ...
>
> The intent resolution mechanism basically revolves around matching an Intent against all of the <intent-filter> descriptions in the installed application packages. ...

### Intent MIME type

From https://developer.android.com/guide/topics/providers/content-provider-basics#MIMETypeReference :

> Content providers can return standard MIME media types, or custom MIME type strings, or both.
>
> MIME types have the format
> ```
> type/subtype
> ```
> ...
>
> Custom MIME type strings, also called "vendor-specific" MIME types, have more complex type and subtype values. The type value is always
> ```
> vnd.android.cursor.dir
> ```
> for multiple rows, or
> ```
> vnd.android.cursor.item
> ```
> for a single row.
>
> The subtype is provider-specific. The Android built-in providers usually have a simple subtype. ...
>
> Other provider developers may create their own pattern of subtypes based on the provider's authority and table names. For example, consider a provider that contains train timetables. The provider's authority is `com.example.trains`, and it contains the tables Line1, Line2, and Line3. In response to the content URI
> ```
> content://com.example.trains/Line1
> ```
> for table Line1, the provider returns the MIME type
> ```
> vnd.android.cursor.dir/vnd.example.line1
> ```
> In response to the content URI
> ```
> content://com.example.trains/Line2/5
> ```
> for row 5 in table Line2, the provider returns the MIME type
> ```
> vnd.android.cursor.item/vnd.example.line2
> ```
> Most content providers define contract class constants for the MIME types they use.

### Android built-in providers

From https://developer.android.com/reference/android/provider/package-summary#classes :

> |                       |   |
> | -                     | - |
> | AlarmClock            | The AlarmClock provider contains an Intent action and extras that can be used to start an Activity to set a new alarm or timer in an alarm clock application. |
> | BlockedNumberContract | The contract between the blockednumber provider and applications. |
> | CalendarContract      | The contract between the calendar provider and applications. |
> | CallLog               | The CallLog provider contains information about placed and received calls. |
> | ContactsContract      | The contract between the contacts provider and applications. |
> | DocumentsContract     | Defines the contract between a documents provider and the platform. |
> | MediaStore            | The contract between the media provider and applications. |
> | Settings              | The Settings provider contains global system-level device preferences. |
> | Telephony             | The Telephony provider contains data related to phone operation, specifically SMS and MMS messages, access to the APN list, including the MMSC to use, and the service state. |
> | UserDictionary        | A provider of user defined words for input methods to use for predictive text input. |
> | VoicemailContract     | The contract between the voicemail provider and applications. |
