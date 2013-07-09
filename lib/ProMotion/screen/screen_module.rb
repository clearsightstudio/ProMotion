module ProMotion
  module ScreenModule
    include ProMotion::ScreenNavigation
    include ProMotion::Styling
    include ProMotion::Tabs
    include ProMotion::SplitScreen if NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].include?("2")

    attr_accessor :parent_screen, :first_screen, :modal, :split_screen

    def on_create(args = {})
      unless self.is_a?(UIViewController)
        raise StandardError.new("ERROR: Screens must extend UIViewController or a subclass of UIViewController.")
      end

      self.title = self.class.send(:get_title)

      args.each { |k, v| self.send("#{k}=", v) if self.respond_to?("#{k}=") }

      self.add_nav_bar(args) if args[:nav_bar]
      self.navigationController.toolbarHidden = !args[:toolbar] unless args[:toolbar].nil?
      self.on_init if self.respond_to?(:on_init)
      self.screen_setup
      self
    end

    def screen_setup
    end

    def modal?
      self.modal == true
    end

    def nav_bar?
      !!self.navigation_controller
    end

    def navigation_controller
      @navigation_controller ||= self.navigationController
    end

    def navigation_controller=(val)
      @navigation_controller = val
      val
    end

    def add_nav_bar(args = {})
      self.navigation_controller ||= begin
        self.first_screen = true if self.respond_to?(:first_screen=)
        nav = NavigationController.alloc.initWithRootViewController(self)
        nav.setModalTransitionStyle(args[:transition_style]) if args[:transition_style]
        nav.setModalPresentationStyle(args[:presentation_style]) if args[:presentation_style]
        nav
      end
    end

    def set_nav_bar_right_button(title, args={})
      args[:title] = title
      set_nav_bar_button :right, args
    end

    def set_nav_bar_left_button(title, args={})
      args[:title] = title
      set_nav_bar_button :left, args
    end

    def set_nav_bar_button(side, args={})
      args[:style]  ||= UIBarButtonItemStyleBordered
      args[:target] ||= self
      args[:action] ||= nil
      button_type = args[:image] || args[:button] || args[:system_icon] || args[:title] || "Button"

      button = bar_button_item button_type, args

      self.navigationItem.leftBarButtonItem = button if side == :left
      self.navigationItem.rightBarButtonItem = button if side == :right

      button
    end

    def bar_button_item(button_type, args)
      case button_type
      when UIBarButtonItem
        button_type
      when UIImage
        UIBarButtonItem.alloc.initWithImage(button_type, style: args[:style], target: args[:target], action: args[:action])
      when String
        UIBarButtonItem.alloc.initWithTitle(button_type, style: args[:style], target: args[:target], action: args[:action])
      else
        if args[:system_icon]
          UIBarButtonItem.alloc.initWithBarButtonSystemItem(args[:system_icon], target: args[:target], action: args[:action])
        else
          PM.logger.error("Please supply a title string, a UIImage or :system.")
          nil
        end
      end
    end

    def first_screen?
      self.first_screen == true
    end

    def view_did_load; end

    def view_will_appear(animated)
      self.will_appear

      self.will_present if isMovingToParentViewController
    end
    def will_appear; end
    def will_present; end

    def view_did_appear(animated)
      self.on_appear

      self.on_presented if isMovingToParentViewController
    end
    def on_appear; end
    def on_presented; end

    def view_will_disappear(animated)
      self.will_disappear

      self.will_dismiss if isMovingFromParentViewController
    end
    def will_disappear; end
    def will_dismiss; end

    def view_did_disappear(animated)
      self.on_disappear

      self.on_dismiss if isMovingFromParentViewController
    end
    def on_disappear; end
    def on_dismiss; end

    def should_rotate(orientation)
      case orientation
      when UIInterfaceOrientationPortrait
        return supported_orientation?("UIInterfaceOrientationPortrait")
      when UIInterfaceOrientationLandscapeLeft
        return supported_orientation?("UIInterfaceOrientationLandscapeLeft")
      when UIInterfaceOrientationLandscapeRight
        return supported_orientation?("UIInterfaceOrientationLandscapeRight")
      when UIInterfaceOrientationPortraitUpsideDown
        return supported_orientation?("UIInterfaceOrientationPortraitUpsideDown")
      else
        false
      end
    end

    def will_rotate(orientation, duration)
    end

    def should_autorotate
      true
    end

    def on_rotate
    end

    def supported_orientation?(orientation)
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].include?(orientation)
    end

    def supported_orientations
      orientations = 0
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].each do |ori|
        case ori
        when "UIInterfaceOrientationPortrait"
          orientations |= UIInterfaceOrientationMaskPortrait
        when "UIInterfaceOrientationLandscapeLeft"
          orientations |= UIInterfaceOrientationMaskLandscapeLeft
        when "UIInterfaceOrientationLandscapeRight"
          orientations |= UIInterfaceOrientationMaskLandscapeRight
        when "UIInterfaceOrientationPortraitUpsideDown"
          orientations |= UIInterfaceOrientationMaskPortraitUpsideDown
        end
      end
      orientations
    end

    def supported_device_families
      NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].map do |m|
        # TODO: What about universal apps?
        case m
        when "1"
          :iphone
        when "2"
          :ipad
        end
      end
    end

    def supported_device_family?(family)
      supported_device_families.include?(family)
    end

    def bounds
      return self.view_or_self.bounds
    end

    def frame
      return self.view_or_self.frame
    end

    # Class methods
    module ClassMethods
      def debug_mode
        @debug_mode
      end

      def debug_mode=(v)
        @debug_mode = v
      end

      def title(t)
        @title = t
      end
      def title=(t)
        @title = t
      end
      def get_title
        @title ||= self.to_s
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
