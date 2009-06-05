framework 'qtkit'

mview = movie_view :layout => {:expanded => [:width, :height]},
                   :movie => movie(:file => "/Users/mario/Movies/Language_Shootout_Promo.mov"),
                   :controller_buttons => [:back, :volume],
                   :fill_color => color(:name => :black)


def mview.keyDown(event)
  leave_full_screen
end
