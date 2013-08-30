## 0.1.4

* Added a generator to create modules from the command-line. Thanks to Guilherme Cavalcanti <guiocavalcanti> for working on this.
* We always use `request.body.read` now, however, we call `rewind` beforehand.

## 0.1.3

* Fix a bug where `TestCase` wouldn't work in 3.2.

## 0.1.2

* Introducing a check where `request.body.read` is called (as usual) if `request.body.string` isn't present. This is due to some faulty behaviour in Rails and some web servers that don't provide a properly working `#read`, as it's the Rack rule. Should finally fix https://github.com/apotonick/roar-rails/issues/18 and friends.
* `TestCase#process` no longer triggers a deprecation warning for Rails > 3.1.
* Now allows using roar >= 0.11.

## 0.1.1

* Added the `represented_formats: [...]` option to be passed to `#respond_with` for either suppressing roar-rails from extending/decorating models when rendering or to fine-tune so this will only happen on white-listed formats as `:hal`. This can also be set globally using `config.representer.represented_formats`.

## 0.1.0

* `ActiveRecord::Relation` is now detected as a collection and the appropriate representer should be found.
* Entity (singular) representers are now correctly infered even if you only specified `collection:` in `::represents`. That works by querying the model.
* Entity representers are now *namespaced* when guessed (i.e., when you didn't specify them explicitly in `::represents`) as it works with collection representers already. If you have a namespaced controller and it suddenly doesn't find its entity representer anymore, either namespace the representer or specify its name in `::represents`.

## 0.0.14

* Moved logic to infer representer names from `ControllerAdditions` to `RepresenterComputer` class.
* Representer names passed to `::represents` are now constantized at runtime where they are actually needed, only. This fixes a bug where you were required to provide a `SingersRepresenter` (for collections) everywhere even when you just want to represent singular resources.
* You can now pass strings to `::represents` as representer names.

## 0.0.13

* Allow passing user options to both `#respond_with` and `#consume!`.
* Fixing `#consume!` with decorators.

## 0.0.12

* Bumping representable to 1.4 which allows us using both extend and decorating representers.

## 0.0.11

* Back to `request.body.read` in `#consume!` (again). If anyone is having problems with empty incoming strings this is a Rails issue - update ;-)

## 0.0.10

* Empty resources now work properly in Rails 3.0 and 3.1.

## 0.0.9

* Changed `request.body.string` to `read` to make it work with Unicorn.

## 0.0.8

* Added `#represents` to configure consuming and rendering on controller class layer. This also calls `respond_to`.

## 0.0.7

* Introduce `:represent_with` and `:represent_items_with` for `#respond_with`. In turn, deprecate the old behaviour since it will change in 1.0.

## 0.0.6

* Make roar-rails rely on roar 0.10 and bigger.

## 0.0.4

* Added `#consume!` to infer representer name and parse the incoming document for a model.

## 0.0.3

* Works with Rails 3.0 now, too. Fixed the `mounted_helpers` import.
