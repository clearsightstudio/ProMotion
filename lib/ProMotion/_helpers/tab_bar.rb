# [DEPRECATED]
# Replaced by ScreenTabs module.
module ProMotion
  class TabBar
    class << self
      def create_tab_bar_controller_from_data(data)
        warn "[DEPRECATION] `create_tab_bar_controller_from_data` is deprecated. Use `open_tab_bar` instead."

        data = self.set_tags(data)

        tab_bar_controller = UITabBarController.alloc.init
        tab_bar_controller.viewControllers = self.tab_controllers_from_data(data)

        return tab_bar_controller
      end

      def set_tags(data)
        warn "[DEPRECATION] `set_tags` is deprecated."
        tag_number = 0
        
        data.each do |d|
          d[:tag] = tag_number
          tag_number += 1
        end

        return data
      end

      def tab_bar_icon(icon, tag)
        warn "[DEPRECATION] `TabBar.tab_bar_icon` is deprecated. Use `create_tab_bar_icon` in ScreenTabs instead."
        return UITabBarItem.alloc.initWithTabBarSystemItem(icon, tag: tag)
      end

      def tab_bar_icon_custom(title, image_name, tag)
        warn "[DEPRECATION] `TabBar.tab_bar_icon_custom` is deprecated. Use `create_tab_bar_icon_custom` in ScreenTabs instead."
        icon_image = UIImage.imageNamed(image_name)
        return UITabBarItem.alloc.initWithTitle(title, image:icon_image, tag:tag)
      end

      def tab_controllers_from_data(data)
        warn "[DEPRECATION] `tab_controllers_from_data` is deprecated. Use `open_tab_bar` instead."
        tab_controllers = []

        data.each do |tab|
          tab_controllers << self.controller_from_tab_data(tab)
        end

        return tab_controllers
      end

      def controller_from_tab_data(tab)
        warn "[DEPRECATION] `controller_from_tab_data` is deprecated. Use `open_tab_bar` instead."
        tab[:badge_number] ||= tab[:badgeNumber]
        tab[:navigation_controller] ||= tab[:navigationController]

        tab[:badge_number] = 0 unless tab[:badge_number]
        tab[:tag] = 0 unless tab[:tag]
        
        view_controller = tab[:view_controller]
        view_controller = tab[:view_controller].alloc.init if tab[:view_controller].respond_to?(:alloc)
        
        if tab[:navigation_controller]
          controller = UINavigationController.alloc.initWithRootViewController(view_controller)
        else
          controller = view_controller
        end

        view_controller.tabBarItem = self.tabBarItem(tab)
        view_controller.tabBarItem.title = view_controller.title unless tab[:title]

        return controller
      end

      def tab_bar_item(tab)
        warn "[DEPRECATION] `TabBar.tab_bar_item` is deprecated. Use `tab_bar_item` in ScreenTabs instead."
        title = "Untitled"
        title = tab[:title] if tab[:title]
        tab[:tag] ||= @current_tag ||= 0
        @current_tag = tab[:tag] + 1
        
        tab_bar_item = tab_bar_icon(tab[:system_icon], tab[:tag]) if tab[:system_icon]
        tab_bar_item = tab_bar_icon_custom(title, tab[:icon], tab[:tag]) if tab[:icon]
        
        tab_bar_item.badgeValue = tab[:badge_number].to_s unless tab[:badge_number].nil? || tab[:badge_number] <= 0
        
        return tab_bar_item
      end

      def select(tab_bar_controller, title: title)
        warn "[DEPRECATION] `TabBar.select` is deprecated. Use `open_tab` in ScreenTabs instead."
        root_controller = nil
        tab_bar_controller.viewControllers.each do |vc|
          if vc.tabBarItem.title == title
            tab_bar_controller.selectedViewController = vc
            root_controller = vc
            break
          end
        end
        root_controller
      end

      def select(tab_bar_controller, tag: tag)
        warn "[DEPRECATION] `TabBar.select:tag:` is deprecated. Use `open_tab` in ScreenTabs instead."
        tab_bar_controller.selectedIndex = tag
      end

      def replace_current_item(tab_bar_controller, view_controller: vc)
        warn "[DEPRECATION] `TabBar.replace_current_item` is deprecated. Use `replace_current_item` in ScreenTabs instead."
        controllers = NSMutableArray.arrayWithArray(tab_bar_controller.viewControllers)
        controllers.replaceObjectAtIndex(tab_bar_controller.selectedIndex, withObject: vc)
        tab_bar_controller.viewControllers = controllers
      end
    end
  end
end