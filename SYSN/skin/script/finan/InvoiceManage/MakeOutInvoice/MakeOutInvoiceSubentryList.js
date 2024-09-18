$(function () {
    //分项统计检索条件切
    subentryTypeChange();

    $(document).on('click', '#SubentryType_0', function (e) {
        subentryTypeChange();
    });

    $(document).on('click', '.rep_serch_item', function (e) {
        subentryTypeChange();
    });
});