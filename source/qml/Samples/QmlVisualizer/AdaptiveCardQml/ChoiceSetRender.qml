import "AdaptiveCardUtils.js" as AdaptiveCardUtils
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Column {
    id: choiceSet

    property var _adaptiveCard
    property var _id
    property bool _isRequired: false
    property string _mEscapedLabelString
    property string _mEscapedErrorString
    property string _mEscapedPlaceholderString
    property var _choiceSetModel
    property bool _isMultiselect: false
    property var _dataType
    property var _dataSet
    property bool showErrorMessage: false
    property string _elementType
    property int minWidth: CardConstants.comboBoxConstants.choiceSetMinWidth
    property int _comboboxCurrentIndex
    property string selectedValues: ""

    function validate() {
        if (showErrorMessage) {
            if (selectedValues)
                showErrorMessage = false;

        }
        return !selectedValues;
    }

    function getAccessibleName() {
        let accessibleName = '';
        if (showErrorMessage === true)
            accessibleName += "Error. " + _mEscapedErrorString + '. ';

        accessibleName += _mEscapedLabelString + '. ';
        return accessibleName;
    }

    width: parent.width
    onActiveFocusChanged: {
        if (activeFocus)
            nextItemInFocusChain().forceActiveFocus();

    }

    InputLabel {
        id: _choiceSetLabel

        _label: _mEscapedLabelString
        _required: _isRequired
        visible: _label.length
    }

    Loader {
        id: comboboxLoader

        height: item ? item.height : 0
        width: parent.width
        active: _elementType === "Combobox"

        sourceComponent: ComboboxRender {
            id: comboBox

            _model: _choiceSetModel
            _mEscapedPlaceholderString: choiceSet._mEscapedPlaceholderString
            _currentIndex: _comboboxCurrentIndex
            _consumer: choiceSet
            _adaptiveCard: choiceSet._adaptiveCard
            Component.onCompleted: {
                selectionChanged.connect(function() {
                    choiceSet.selectedValues = currentValue ? currentValue : "";
                    if (_isRequired)
                        validate();

                });
                choiceSet.selectedValues = currentValue ? currentValue : "";
            }
        }

    }

    Loader {
        id: filteredLoader

        height: item ? item.height : 0
        width: parent.width
        active: _elementType === "Filtered"

        function onFetchChoices(text) {
            choiceSet._adaptiveCard.fetchFilteredChoices(choiceSet._dataSet, text, choiceSet._id);
        }

        sourceComponent: FilteredChoiceSetRender {
            id: filtered
            _id: choiceSet._id
            _model: _choiceSetModel
            _mEscapedPlaceholderString: choiceSet._mEscapedPlaceholderString
            _currentIndex: _comboboxCurrentIndex
            _consumer: choiceSet
            _adaptiveCard: choiceSet._adaptiveCard
            _isMultiselect: choiceSet._isMultiselect
            _dataSet: choiceSet._dataSet
            _dataType: choiceSet._dataType
            Component.onCompleted: {
                selectionChanged.connect(function() {
                    choiceSet.selectedValues = selectedChoices[0] ? selectedChoices[0].valueOn : "";
                    for (let index = 1; index < selectedChoices.length; index++) {
                        choiceSet.selectedValues = choiceSet.selectedValues + "," + selectedChoices[index].valueOn;
                    }
                    if (_isRequired)
                        validate();

                });
                fetchChoices.connect(filteredLoader.onFetchChoices);
            }
        }

    } 

    Loader {
        id: radioButtonLoader

        height: item ? item.height : 0
        width: parent.width
        active: _elementType === "RadioButton"

        sourceComponent: Rectangle {
            id: radioButtonRectangle

            property int focusRadioIndex: 0

            height: radioButtonListView.height
            width: parent.width
            color: "transparent"
            onActiveFocusChanged: {
                if (activeFocus)
                    radioButtonGroup.buttons[focusRadioIndex].forceActiveFocus();

            }

            ButtonGroup {
                id: radioButtonGroup

                function onSelectionChanged() {
                    choiceSet.selectedValues = AdaptiveCardUtils.onSelectionChanged(radioButtonGroup, false);
                    if (_isRequired)
                        validate();

                }

                buttons: radioButtonListView.contentItem.children
                exclusive: true
            }

            ListView {
                id: radioButtonListView

                function focusRadioButtons(focusIndex) {
                    radioButtonRectangle.focusRadioIndex = focusIndex;
                    radioButtonGroup.buttons[radioButtonRectangle.focusRadioIndex].checked = true;
                    radioButtonGroup.buttons[radioButtonRectangle.focusRadioIndex].forceActiveFocus();
                }

                height: contentItem.height
                width: parent.width
                model: _choiceSetModel
                keyNavigationEnabled: false

                delegate: CustomRadioButton {
                    _adaptiveCard: choiceSet._adaptiveCard
                    _rbValueOn: valueOn
                    _rbisWrap: isWrap
                    _rbTitle: title
                    _rbIsChecked: isChecked
                    _consumer: choiceSet
                    Component.onCompleted: {
                        selectionChanged.connect(radioButtonGroup.onSelectionChanged);
                        if (_rbIsChecked)
                            radioButtonRectangle.focusRadioIndex = index;

                    }
                }

            }

        }

    }

    Loader {
        id: checkBoxLoader

        height: item ? item.height : 0
        width: parent.width
        active: _elementType === "CheckBox"

        sourceComponent: Rectangle {
            id: checkBoxRectangle

            height: checkBoxListView.height
            width: parent.width
            color: "transparent"

            ButtonGroup {
                id: checkBoxButtonGroup

                function onSelectionChanged() {
                    choiceSet.selectedValues = AdaptiveCardUtils.onSelectionChanged(checkBoxButtonGroup, true);
                    if (_isRequired)
                        validate();

                }

                buttons: checkBoxListView.contentItem.children
                exclusive: false
            }

            ListView {
                id: checkBoxListView

                height: contentItem.height
                width: parent.width
                model: _choiceSetModel
                keyNavigationEnabled: false

                delegate: CustomCheckBox {
                    _adaptiveCard: choiceSet._adaptiveCard
                    _cbValueOn: valueOn
                    _cbisWrap: isWrap
                    _cbTitle: title
                    _cbIsChecked: isChecked
                    _consumer: choiceSet
                    Component.onCompleted: {
                        selectionChanged.connect(checkBoxButtonGroup.onSelectionChanged);
                    }
                }

            }

        }

    }

    InputErrorMessage {
        id: _choiceSetErrorMessage

        _errorMessage: _mEscapedErrorString
        visible: showErrorMessage
    }

}
