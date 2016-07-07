package clusters

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"github.com/go-openapi/errors"
	"github.com/go-openapi/runtime"

	strfmt "github.com/go-openapi/strfmt"
)

// NewFindSingleClusterParams creates a new FindSingleClusterParams object
// with the default values initialized.
func NewFindSingleClusterParams() *FindSingleClusterParams {
	var ()
	return &FindSingleClusterParams{}
}

/*FindSingleClusterParams contains all the parameters to send to the API endpoint
for the find single cluster operation typically these are written to a http.Request
*/
type FindSingleClusterParams struct {

	/*Name
	  Name of the cluster

	*/
	Name string
}

// WithName adds the name to the find single cluster params
func (o *FindSingleClusterParams) WithName(Name string) *FindSingleClusterParams {
	o.Name = Name
	return o
}

// WriteToRequest writes these params to a swagger request
func (o *FindSingleClusterParams) WriteToRequest(r runtime.ClientRequest, reg strfmt.Registry) error {

	var res []error

	// path param name
	if err := r.SetPathParam("name", o.Name); err != nil {
		return err
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}