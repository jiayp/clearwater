require 'clearwater/component'

module Clearwater
  module CachedRender
    def self.included base
      %x{
        Opal.defn(self, 'type', 'Thunk');
        Opal.defn(self, 'render', function(prev) {
          var self = this;

          if(prev && prev.vnode && #{!should_render?(`prev`)}) {
            return prev.vnode;
          } else {
            self.dom_node = self.dom_node || #{Clearwater::DOMReference.new}
            self.node = #{Component.sanitize_content(render)};
            self.node.properties['ref'] = #{@dom_node};
            return self.node;
          }
        });
      }
    end

    def should_render? _
      false
    end

    def update!
      return if @will_render
      @will_render = true
      Bowser.window.animation_frame {
#              Bowser.window.delay(0.001) {
        node = Component.sanitize_content(render)
        diff = VirtualDOM.diff @node, node
        tree = @dom_node.JS[:node].JS[:native]
        VirtualDOM.patch tree, diff
        @node = node
        @will_render = false
      }
    end
  end
end
