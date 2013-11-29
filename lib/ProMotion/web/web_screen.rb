motion_require '../cocoatouch/view_controller'
motion_require '../screen/screen_module'
motion_require 'web_screen_module'

module ProMotion
  class WebScreen < ViewController
    include ProMotion::ScreenModule
    include ProMotion::WebScreenModule
  end
end
