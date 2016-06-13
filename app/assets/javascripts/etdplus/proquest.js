function add_cmte_member() {
  var idx = $("div[id^='cmte_member_name_']").length;
  $("<div></div>").attr("id", "cmte_member_name_"+idx).appendTo("#cmte_member");
  $("#cmte_member_name_"+idx).append($('<label for="cmte_surname_' + idx + '">Last Name</label>'));
  $("#cmte_member_name_"+idx).append('<input id="cmte_surname_' + idx + '" name="cmte_surname_' + idx + '" type="text" />');
  $("#cmte_member_name_"+idx).append($('<label for="cmte_fname_' + idx + '">First Name</label>'));
  $("#cmte_member_name_"+idx).append('<input id="cmte_fname_' + idx + '" name="cmte_fname_' + idx + '" type="text" />');
  $("#cmte_member_name_"+idx).append($('<label for="cmte_mname_' + idx + '">Middle Name</label>'));
  $("#cmte_member_name_"+idx).append('<input id="cmte_mname_' + idx + '" name="cmte_mname_' + idx + '" type="text" />');
  $("#cmte_member_name_"+idx).append($('<label for="cmte_suffix_' + idx + '">Suffix</label>'));
  $("#cmte_member_name_"+idx).append('<input id="cmte_suffix_' + idx + '" name="cmte_suffix_' + idx + '" type="text" />');
  $("#cmte_member_name_"+idx).append($('<label for="cmte_affiliation_' + idx + '">Affiliation</label>'));
  $("#cmte_member_name_"+idx).append('<input id="cmte_affiliation_' + idx + '" name="cmte_affiliation_' + idx + '" type="text" />');
}
 
function add_category() {
  var idx = $("div[id^='proquest_category_']").length;
  $("<div></div>").attr("id", "proquest_category_"+idx).appendTo("#categorization");
  $("#proquest_category_"+idx).append($('<label for="cat_code_' + idx + '">Category Code</label>'));
  $("#proquest_category_"+idx).append('<input id="cat_code_' + idx + '" name="cat_code_' + idx + '" type="text" />');
  $("#proquest_category_"+idx).append($('<label for="cat_desc_' + idx + '">Category Description</label>'));
  $("#proquest_category_"+idx).append('<input id="cat_desc_' + idx + '" name="cat_desc_' + idx + '" type="text" />');
}

// once the "ProQuest ETD" resource type is chosen,
// proquest specific fields are added to the form
function expand_proquest_form(){
  var proquest_selected = $("#collection_resource_type option:selected").is(':contains("ProQuest ETD")');
  $("#proquest_inputs").toggleClass('hidden', !proquest_selected);
}

function getProQuestJson() {
  var keywords = 
    $('input[name="collection[tag][]"]').map(function() {
      return $(this).val();
    }).toArray().join(', ');
  var language = 
    $('input[name="collection[language][]"]').map(function() {
      return $(this).val();
    }).toArray().join(', ');
  var author_name = {
    "DISS_surname": $("#author_surname").val(),
    "DISS_fname": $("#author_fname").val(), 
    "DISS_middle": $("#author_mname").val(), 
    "DISS_suffix": $("#author_suffix").val(), 
    "DISS_affiliation": $("#author_affiliation").val()};
  var author_phone_fax = {
    "DISS_cntry_cd": $("#author_phone_cntry_code").val(), 
    "DISS_area_code": $("#author_phone_area_code").val(), 
    "DISS_phone_num": $("#author_phone_num").val(),
    "DISS_phone_ext": $("#author_phone_ext").val()};
  var author_address = {
    "DISS_addrline": $("#author_addrline").val(), 
    "DISS_city": $("#author_city").val(),
    "DISS_st": $("#author_st").val(), 
    "DISS_pcode": $("#author_pcode").val(), 
    "DISS_country": $("#author_country").val()}; 
  var author_contact = {
    "DISS_contact_effdt": $("#author_contact_effdt").val(), 
    "DISS_phone_fax": author_phone_fax,
    "DISS_address": author_address, 
    "DISS_email": $("#author_email").val()};
  var diss_author = {"DISS_name": author_name, 
                     "DISS_contact": author_contact};
  var diss_authorship = {"DISS_author": diss_author};
  var diss_dates = {"DISS_comp_date": $("#comp_date").val(), 
                    "DISS_accept_date": $("#accept_date").val()}; 
  var diss_institution = {
    "DISS_inst_code": $("#inst_code").val(),
    "DISS_inst_name": $("#inst_name").val(), 
    "DISS_inst_contact": $("#inst_contact").val()}; 
  var advisor_name = {
    "DISS_surname": $("#advisor_surname").val(), 
    "DISS_fname": $("#advisor_fname").val(), 
    "DISS_middle": $("#advisor_mname").val(), 
    "DISS_suffix": $("#advisor_suffix").val(), 
    "DISS_affiliation": $("#advisor_affiliation").val()}; 
  var diss_advisor = {"DISS_name": advisor_name};
  var diss_cmte_members = new Array();
  var num_cmte_members = $("div[id^='cmte_member_name_']").length;
  for (var i = 0; i < num_cmte_members; i++) {
    diss_cmte_members[i] = {"DISS_name": {
      "DISS_surname": $("#cmte_surname"+i).val(),
      "DISS_fname": $("#cmte_fname"+i).val(),
      "DISS_middle": $("#cmte_mname"+i).val(), 
      "DISS_suffix": $("#cmte_surname"+i).val(),  
      "DISS_affiliation": $("#cmte_affiliation"+i).val()}};
  }
  var diss_categories = new Array();
  var num_categories = $("div[id^='proquest_category_']").length;
  for (var i = 0; i < num_categories; i++) {
    diss_categories[i] = {"DISS_category":{
      "DISS_cat_code": $("#cat_code"+i).val(),
      "DISS_cat_desc": $("#cat_desc"+i).val()}};
  }
  var diss_description = {
    "DISS_title": $("#collection_title").val(),  
    "DISS_dates": diss_dates,
    "DISS_degree": $("#degree").val(),
    "DISS_institution": diss_institution,
    "DISS_advisor": diss_advisor,
    "DISS_cmte_member": diss_cmte_members,
    "DISS_categorization": {"DISS_categories": diss_categories,
                            "DISS_keyword": keywords, 
                            "DISS_language": language}};
  var diss_content = {"DISS_abstract":{"DISS_para": $("#collection_description").val()},
                      "DISS_binary": $("#main_etd_pdf").val()};
  var diss_submission = {"DISS_authorship": diss_authorship, 
                          "DISS_description": diss_description, 
                          "DISS_content": diss_content};
  var proquest_json = {"DISS_submission": diss_submission};
  if ($("#proquest_inputs").is(":hidden"))
    return null;
  else
    return JSON.stringify(proquest_json);
  end
}

Blacklight.onLoad(function() {
  $('a[disabled=disabled]').click(function(event){
    event.preventDefault(); // Prevent link from following its href
  });
  
  $("#collection_resource_type").click(function() {
    expand_proquest_form();
  });

  $('input[type="submit"][name$="_collection"]').click(function(event) {
    $("#collection_proquest_inputs").attr('value', getProQuestJson());
  });
  
});
