const { createRoot } = ReactDOM;
const { useState } = React;
const { Button, Alert, Drawer, Divider, Space, Table, Tag, Tabs, Descriptions, Radio, DatePicker, Form, Input, InputNumber, Select, Upload } = antd;
const App = () => {
    const [open, setOpen] = useState(false);
    const [editDeclarationDrawer, setEditDeclarationDrawer] = useState(false);
    const [addDeclarationDrawer, setAddDeclarationDrawer] = useState(false);
    const [viewDeclarationCorrespondenceDrawer, setViewDeclarationCorrespondenceDrawer] = useState(false);
    const [claimedDrawer, setClaimedDrawer] = useState(false);
    const showDrawer = () => {
        setOpen(true);
    };
    const onClose = () => {
        setOpen(false);
    };
    const showAddDeclarationDrawer = () => {
        setAddDeclarationDrawer(true);
    };
    const onAddDeclarationDrawerClose = () => {
        setAddDeclarationDrawer(false);
    };
    const showEditDeclarationDrawer = () => {
        setEditDeclarationDrawer(true);
    };
    const onEditDeclarationDrawerClose = () => {
        setEditDeclarationDrawer(false);
    };
    const showClaimedDrawer = () => {
        setClaimedDrawer(true);
    };
    const onClaimedDrawerClose = () => {
        setClaimedDrawer(false);
    };
    const showDeclarationCorrespondenceDrawer = () => {
        setViewDeclarationCorrespondenceDrawer(true);
    };
    const onDeclarationCorrespondenceDrawerClose = () => {
        setViewDeclarationCorrespondenceDrawer(false);
    };
    const [componentSize, setComponentSize] = useState("default");
    const [selectedDeclarationVia, setSelectedDeclarationVia] = useState(null);
    const handleSelectChange = (value) => {
        setSelectedDeclarationVia(value);
    };
    const onFormLayoutChange = ({ size }) => {
        setComponentSize(size);
    };
    const { TextArea } = Input;
    return (React.createElement(React.Fragment, null,
        React.createElement(Button, { type: "default", onClick: showDrawer }, "Gift Aid History"),
        React.createElement(Drawer, { title: "Gift Aid History", width: 800, closable: true, onClose: onClose, open: open, extra: React.createElement(Space, null,
                React.createElement(Button, { onClick: showAddDeclarationDrawer, type: "primary" }, "Add Declaration")) },
            React.createElement(Tabs, null,
                React.createElement(Tabs.TabPane, { tab: "Statuses", key: "tab1" },
                    React.createElement("div", { onClick: showClaimedDrawer },
                        React.createElement(Table, { columns: statuses, dataSource: table1 }))),
                React.createElement(Tabs.TabPane, { tab: "Declarations", key: "tab2" },
                    React.createElement("div", { onClick: showEditDeclarationDrawer },
                        React.createElement(Table, { columns: declarations, dataSource: table2 })))),
            React.createElement(Drawer, { title: "Add Declaration", width: 480, closable: false, onClose: onAddDeclarationDrawerClose, open: addDeclarationDrawer, extra: React.createElement(Space, null,
                    React.createElement(Button, { onClick: onAddDeclarationDrawerClose }, "Close"),
                    React.createElement(Button, { onClick: onAddDeclarationDrawerClose, type: "primary" }, "Save")) },
                React.createElement(Form
                // labelCol={{ span: 4 }}
                // wrapperCol={{ span: 14 }}
                , { 
                    // labelCol={{ span: 4 }}
                    // wrapperCol={{ span: 14 }}
                    layout: "vertical", initialValues: { size: componentSize }, onValuesChange: onFormLayoutChange, size: "default", style: { maxWidth: 480 } },
                    React.createElement(Space, { size: "middle" },
                        React.createElement(Form.Item, { label: "Gift Aid", name: "size" },
                            React.createElement(Radio.Group, { buttonStyle: "solid" },
                                React.createElement(Radio.Button, { value: "default" }, "Yes"),
                                React.createElement(Radio.Button, { value: "large" }, "No"))),
                        React.createElement(Form.Item, { label: "Declaration Date" },
                            React.createElement(DatePicker, null))),
                    React.createElement(Form.Item, { label: "Declared Via" },
                        React.createElement(Space, { size: "small", direction: "vertical", style: { width: "100%" } },
                            React.createElement(Select, { onChange: handleSelectChange },
                                React.createElement(Select.Option, { value: "1" }, "Web Form"),
                                React.createElement(Select.Option, { value: "2" }, "Phone")),
                            selectedDeclarationVia === '2' && (React.createElement(Alert, { message: "Verbal Declaration Method", description: "Gift Aid will be eligible 30 days after the declaration date (UK only)", type: "warning" })))),
                    React.createElement(Form.Item, { label: "Attachments" },
                        React.createElement(Form.Item, { name: "dragger", valuePropName: "fileList", noStyle: true },
                            React.createElement(Upload.Dragger, { name: "files" },
                                React.createElement("p", { className: "ant-upload-drag-icon" }),
                                React.createElement("p", { className: "ant-upload-text" }, "Click or drag file to this area to upload"),
                                React.createElement("p", { className: "ant-upload-hint" }, "Support for a single or bulk upload.")))),
                    React.createElement(Form.Item, { label: "Notes" },
                        React.createElement(TextArea, { rows: 4 })))),
            React.createElement(Drawer, { title: "Edit Declaration", width: 480, closable: false, onClose: onEditDeclarationDrawerClose, open: editDeclarationDrawer, extra: React.createElement(Space, null,
                    React.createElement(Button, { onClick: onEditDeclarationDrawerClose }, "Close"),
                    React.createElement(Button, { onClick: onEditDeclarationDrawerClose, type: "primary" }, "Save")) },
                React.createElement("div", { style: { position: 'absolute', top: '84px', right: '24px' } },
                    React.createElement(Button, { onClick: showDeclarationCorrespondenceDrawer }, "Show Correspondence")),
                React.createElement(Drawer, { title: "Confirmation Correspondence(s)", width: 800, closable: true, onClose: onDeclarationCorrespondenceDrawerClose, open: viewDeclarationCorrespondenceDrawer }, "*Email or PDF previewer that show the gift aid confirmation*"),
                React.createElement(Descriptions, { bordered: true, title: "Declaration Details", layout: "vertical", items: declarationDesc }),
                React.createElement("br", null),
                React.createElement(Divider, null),
                React.createElement(Form
                // labelCol={{ span: 4 }}
                // wrapperCol={{ span: 14 }}
                , { 
                    // labelCol={{ span: 4 }}
                    // wrapperCol={{ span: 14 }}
                    layout: "vertical", initialValues: { size: componentSize }, onValuesChange: onFormLayoutChange, size: "default", style: { maxWidth: 480 } },
                    React.createElement(Space, { size: "middle" },
                        React.createElement(Form.Item, { label: "Gift Aid", name: "size" },
                            React.createElement(Radio.Group, { buttonStyle: "solid" },
                                React.createElement(Radio.Button, { value: "default" }, "Yes"),
                                React.createElement(Radio.Button, { value: "large" }, "No"))),
                        React.createElement(Form.Item, { label: "Declaration Date" },
                            React.createElement(DatePicker, null))),
                    React.createElement(Form.Item, { label: "Declared Via" },
                        React.createElement(Space, { size: "small", direction: "vertical", style: { width: "100%" } },
                            React.createElement(Select, { onChange: handleSelectChange },
                                React.createElement(Select.Option, { value: "1" }, "Web Form"),
                                React.createElement(Select.Option, { value: "2" }, "Phone")),
                            selectedDeclarationVia === '2' && (React.createElement(Alert, { message: "Verbal Declaration Method", description: "Gift Aid will be eligible 30 days after the declaration date (UK only)", type: "warning" })))),
                    React.createElement(Form.Item, { label: "Attachments" },
                        React.createElement(Form.Item, { name: "dragger", valuePropName: "fileList", noStyle: true },
                            React.createElement(Upload.Dragger, { name: "files" },
                                React.createElement("p", { className: "ant-upload-drag-icon" }),
                                React.createElement("p", { className: "ant-upload-text" }, "Click or drag file to this area to upload"),
                                React.createElement("p", { className: "ant-upload-hint" }, "Support for a single or bulk upload.")))),
                    React.createElement(Form.Item, { label: "Notes" },
                        React.createElement(TextArea, { rows: 4 })))),
            React.createElement(Drawer, { title: "Donations Claimed in TD100123", width: 600, closable: true, onClose: onClaimedDrawerClose, open: claimedDrawer },
                React.createElement(Table, { columns: claimedCol, dataSource: claimedTable })))));
};
const ComponentDemo = App;
createRoot(mountNode).render(React.createElement(ComponentDemo, null));
const declarations = [
    {
        title: "Declaration Date",
        dataIndex: "declaracationdate",
        key: "declaracationdate"
    },
    {
        title: "Declared Via",
        dataIndex: "declaredvia",
        key: "declaredvia"
    },
    {
        title: "Opt-in",
        key: "tags",
        dataIndex: "tags",
        render: (_, { tags }) => (React.createElement(React.Fragment, null, tags.map((tag) => {
            let color = tag.length > 5 ? "geekblue" : "green";
            if (tag === "No") {
                color = "volcano";
            }
            return (React.createElement(Tag, { color: color, key: tag }, tag.toUpperCase()));
        })))
    },
    {
        title: "Claimed List",
        key: "action",
        render: (_, record) => (React.createElement(Space, { size: "middle" },
            React.createElement("a", null, "View")))
    },
    {
        title: "Action",
        key: "action",
        render: (_, record) => (React.createElement(Space, { size: "middle" },
            React.createElement("a", null, "Edit")))
    }
];
const table2 = [
    {
        key: "1",
        declaracationdate: "12/12/2024",
        declaredvia: "Web Form",
        tags: ["Yes", "Current"]
    },
    {
        key: "2",
        declaracationdate: "12/12/2024",
        declaredvia: "Phone (inbound)",
        tags: ["No"]
    },
    {
        key: "3",
        declaracationdate: "12/12/2024",
        declaredvia: "Web Form",
        tags: ["Yes"]
    }
];
const statuses = [
    {
        title: "Reference",
        key: "action",
        render: (_, record) => (React.createElement(Space, { size: "middle" },
            React.createElement("a", null, "TD1000123")))
    },
    {
        title: "Eligible From",
        dataIndex: "eligiblefrom",
        key: "eligiblefrom"
    },
    {
        title: "Eligible To",
        dataIndex: "eligibleto",
        key: "eligibleto"
    },
    {
        title: "Status",
        key: "tags",
        dataIndex: "tags",
        render: (_, { tags }) => (React.createElement(React.Fragment, null, tags.map((tag) => {
            let color = tag.length > 5 ? "geekblue" : "green";
            if (tag === "Invalid") {
                color = "volcano";
            }
            return (React.createElement(Tag, { color: color, key: tag }, tag.toUpperCase()));
        })))
    },
    {
        title: "Total Claimed",
        dataIndex: "claimed",
        key: "claimed"
    }
];
const table1 = [
    {
        key: "1",
        eligiblefrom: "12/12/2024",
        eligibleto: "Present",
        tags: ["Valid", "Current"],
        claimed: "£1,234"
    },
    {
        key: "2",
        eligiblefrom: "12/12/2024",
        eligibleto: "12/12/2024",
        tags: ["Invalid"],
        claimed: "N/A"
    },
    {
        key: "3",
        eligiblefrom: "12/12/2024",
        eligibleto: "12/12/2024",
        tags: ["Valid"],
        claimed: "£1,234"
    },
    {
        key: "4",
        eligiblefrom: "12/12/2024",
        eligibleto: "12/12/2024",
        tags: ["Valid"],
        claimed: "£1,234"
    }
];
const claimedCol = [
    {
        title: "Reference",
        dataIndex: "ref",
        key: "ref"
    },
    {
        title: "Date",
        dataIndex: "date",
        key: "date"
    },
    {
        title: "Donation",
        dataIndex: "amount",
        key: "amount"
    },
    {
        title: "Claimed Gift Aid",
        dataIndex: "giftAidAmount",
        key: "giftAidAmount"
    },
    {
        title: "Action",
        key: "action",
        render: (_, record) => (React.createElement(Space, { size: "middle" },
            React.createElement("a", null, "View")))
    }
];
const claimedTable = [
];
// gift aid CRUD section
const declarationDesc = [
    {
        key: "1",
        label: "Full Name",
        children: "Tim Burton"
    },
    {
        key: "4",
        label: "Address",
        span: 2,
        children: "No. 18, Elm Street, E15 290 - Knownwhere"
    }
];
// always visible tax statement
const TaxTable = () => {
    return (React.createElement(React.Fragment, null,
        React.createElement(Table, { columns: taxes, dataSource: taxStatements })));
};
const TableDemo = TaxTable;
createRoot(mountTable).render(React.createElement(TableDemo, null));
const taxes = [
    {
        title: "Reference",
        dataIndex: "ref",
        key: "ref"
    },
    {
        title: "Date",
        dataIndex: "date",
        key: "date"
    },
    {
        title: "Single / Regular",
        dataIndex: "singleRegular",
        key: "singleRegular"
    },
    {
        title: "Gift Aid",
        dataIndex: "giftAid",
        key: "giftAid"
    },
    {
        title: "Amount",
        dataIndex: "amount",
        key: "amount"
    }
];
const taxStatements = [
    {
        key: "1",
        ref: "DN2000XX",
        date: "13/12/2024",
        singleRegular: "Single",
        giftAid: "£0.00",
        amount: "$250.00"
    },
    {
        key: "2",
        ref: "DN1000XX",
        date: "12/12/2024",
        singleRegular: "Single",
        giftAid: "$0.00",
        amount: "$100.00"
    }
];
//
const SelectFiscalYear = () => {
    return (React.createElement(React.Fragment, null,
        React.createElement(Select, { placeholder: "Select Fiscal Year", defaultValue: "2023/2024", optionFilterProp: "children", options: [
                {
                    value: '2023/2024',
                    label: '2023/2024',
                },
                {
                    value: '2022/2023',
                    label: '2022/2023',
                },
                {
                    value: '2021/2022',
                    label: '2021/2022',
                },
            ] })));
};
const SelectDemo = SelectFiscalYear;
createRoot(mountSelect).render(React.createElement(SelectDemo, null));
export {};