## 0.4.0 (2014-06-17)
- auto_writable is disabled by default
    - To restore the previous behavior, set `config.auto_writable = true`.
- Add shorthand methods `SwitchPoint.with_readonly`, `SwitchPoint.with_writable`

## 0.3.1 (2014-06-04)
- Support defaulting to writable ActiveRecord::Base connection
    - When `:writable` key is omitted, ActiveRecord::Base is used for the writable connection.

## 0.3.0 (2014-06-04)
- Improve thread safety
- Raise appropriate error if unknown mode is given to with_connection

## 0.2.3 (2014-06-02)
- Support specifying the same database name within different switch_point
- Add Proxy#readonly? and Proxy#writable? predicate

## 0.2.2 (2014-05-30)
- Fix nil error on with_{readonly,writable} from non-switch_point model

## 0.2.1 (2014-05-29)
- Add Proxy#switch_name to switch proxy configuration
- Fix weird nil error when Config#define_switch_point isn't called yet

## 0.2.0 (2014-05-29)
- Always send destructive operations to writable connection
- Fix bug on pooled connections

## 0.1.0 (2014-05-28)
- Initial release
