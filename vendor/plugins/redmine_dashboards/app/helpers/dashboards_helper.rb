module DashboardsHelper
  def sort_js(dashboard_id, project_id, parent_ids)
    ids = parent_ids.map { |p_id| "#sortable_#{p_id}" }.join(',')
    "
    jQuery(function() {
      jQuery('#{ids}').sortable({
        connectWith: '.sortable',
        placeholder: 'highlight',
        receive: function(event, ui) {
          var b = ui.sender[0].id;
          var a = jQuery(this).sortable('serialize');
          var xhr = new XMLHttpRequest();

          xhr.onreadystatechange = function () {
            if (xhr.readyState == 1) {
            }
            if (xhr.readyState == 4) {
            }
          }
          xhr.open('GET', '/dashboards/sort' + '?id=#{dashboard_id}&project_id=#{project_id}'
            + '&parent_id=' + b + '&' + a);
          xhr.send(null);
        },
        update: function(event, ui) {
          var a = jQuery(this).sortable('serialize');
          var xhr = new XMLHttpRequest();

          xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
            }
          }
          xhr.open('GET', '/dashboards/sort' + '?id=#{dashboard_id}&project_id=#{project_id}'
            + '&parent_id=' + jQuery(this)[0].id + '&' + a);
          xhr.send(null);
}
      });
      jQuery('#{ids}').disableSelection();
    });
    "
  end

  def single_sort_js(dashboard_id, project_id, id)
    "
    jQuery(function() {
      jQuery('##{id}').sortable({
        placeholder: 'highlight',
        update: function(event, ui) {
          var a = jQuery(this).sortable('serialize');
          var xhr = new XMLHttpRequest();

          xhr.onreadystatechange = function () {
            if (xhr.readyState == 1) {
              jQuery('#ajax-indicator').show();
            }
            if (xhr.readyState == 4) {
              jQuery('#ajax-indicator').hide();
            }
          }

          xhr.open('GET', '/dashboards/sort' + '?id=#{dashboard_id}&project_id=#{project_id}'
            + '&' + a);
          xhr.send(null);
        }
      });
      jQuery('##{id}').disableSelection();
    });
    "
  end

  def droppable_js(id, accept, dashboard_id, project_id)
    accept_params = accept.map {|v| "#objectives_#{v.id}"}.join(', ')
    "
    jQuery(function() {
      jQuery('##{id}').droppable({
        hoverClass: 'current',
        tolorent: 'fit',
        drop: function(event, ui) {
          var c = jQuery(ui.draggable).attr('id');
          var xhr = new XMLHttpRequest();

          xhr.onreadystatechange = function () {
            if (xhr.readyState == 1) {
              jQuery('#ajax-indicator').show();
            }
            if (xhr.readyState == 4) {
              if (xhr.responseText == '0') {
                jQuery(ui.draggable).remove();
              }
              jQuery('#ajax-indicator').hide();
            }
          }
          xhr.open('GET', '/dashboards/update_category' + '?id=#{dashboard_id}&project_id=#{project_id}'
            + '&objective_child_id=' + c + '&objective_parent_id=#{id}');
          xhr.send(null);
        }
      });
    });
    "
  end
end

